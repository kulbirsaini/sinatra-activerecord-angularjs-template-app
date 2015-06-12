require File.expand_path('../boot', __FILE__)
require 'sinatra/base'
require 'sinatra/reloader'
require 'sinatra/multi_route'
require 'active_support/all'
require 'logger'
require 'yaml'

# Remove template engines you don't like/want.
require 'tilt/erb'
require 'tilt/rdiscount'

# Credits : https://blog.8thlight.com/justin-herrick/2014/03/07/adding-namespaces-to-ruby.html
# Not required for now.
#def define_nested_modules(mod = Kernel, names)
#  return if names.empty?
#  cur_mod = names.first.classify
#  (mod.const_defined?(cur_mod) ? mod.const_get(cur_mod) : mod.const_set(cur_mod, Module.new)).tap do |this|
#    this.module_exec do
#      extend self
#      define_nested_modules(this, names.drop(1))
#    end
#  end
#end

module SinatraApp
  class Application < Sinatra::Application
    cattr_accessor :connection_info, :db_dir, :migrations_dir, :groups, :models_dir, :controllers_dir, :lib_dir, :layouts_dir_name,
      :log_dir, :log_filepath, :log_file, :logger, :cors_api, :api_routing, :apis, :api_versions, :default_api_version, :global_settings

    def self.sanitize_path(path)
      path.gsub(/(\/)+/, '/').gsub(/\A\//, '').gsub(/\/\z/, '')
    end

    Sinatra::Application.environment = ENV['RACK_ENV'].present? ? ENV['RACK_ENV'].to_sym : :development
    Sinatra::Application.root =  Pathname.new(File.dirname(File.expand_path('../', __FILE__)))

    env_config_file = ENV['SINATRA_CONFIG'] || 'config/sinatra_app.yml'
    # Using HashWithIndifferentAccess to symbolize_keys recursively
    env_config = HashWithIndifferentAccess.new(YAML::load(open(root.join(env_config_file)).read))[environment]

    Sinatra::Application.views = root.join(env_config[:views_dir])
    Sinatra::Application.public_dir = root.join(env_config[:public_dir])
    @@connection_info =  YAML::load(File.open(root.join(env_config[:database_config]))).symbolize_keys
    @@layouts_dir_name = env_config[:layouts_dir_name].is_a?(String) ? env_config[:layouts_dir_name] : 'layouts'
    @@db_dir = root.join(env_config[:db_dir])
    @@migrations_dir = db_dir.join('migrate')
    @@models_dir = root.join(env_config[:models_dir])
    @@controllers_dir = root.join(env_config[:controllers_dir])
    @@lib_dir = root.join(env_config[:lib_dir])
    @@log_dir = root.join(env_config[:log_dir])
    @@log_filepath = log_dir.join("#{environment}.log")
    @@groups = [ :default ] << environment
    @@cors_api = !!env_config[:enable_cors_api]
    @@api_routing = !!env_config[:enable_api_routing]
    @@global_settings = {}

    if api_routing && env_config[:supported_apis].present?
      sanitized_apis = {}
      env_config[:supported_apis].map do |version, api|
        # Paths must be of format api/v1 or api201502. No slash at beginning or end.
        api[:controllers] = api[:controllers].is_a?(String) ? sanitize_path(api[:controllers]) : nil
        api[:models] = api[:models].is_a?(String) ? sanitize_path(api[:models]) : nil
        api[:views] = api[:views].is_a?(String) ? sanitize_path(api[:views]) : nil
        # Path prefix must be of format /api/v1 Slash in front but not at the end.
        api[:path_prefix] = File.join('/', api[:path_prefix].to_s).gsub(/(\/)+/, '/').gsub(/\/\z/, '')
        api[:default] = !!api[:default]
        sanitized_apis[version.to_s] = api
      end
      @@apis = sanitized_apis

      @@api_versions = apis.keys

      default_api = apis.select{ |version, api| api[:default] }.first
      @@default_api_version = default_api.present? ? default_api[0] : apis.first.try(:first)
    else
      @@api_routing = false
      @@apis = {}
      @@api_versions = []
      @@default_api_version = nil
    end

    @@log_file = File.new(log_filepath, 'a+')
    log_file.sync = true
    @@logger = Logger.new(log_filepath)

    def initialize(options = {})
      super
      ActiveRecord::Base.establish_connection(self.class.connection_info[self.class.environment])
    end
  end
end

Bundler.require(*SinatraApp::Application.groups)

Dir.glob(SinatraApp::Application.lib_dir.join('*.rb')).each{ |f| require f }
Dir.glob(SinatraApp::Application.lib_dir.join('tasks/*.rake')).each{ |f| import f }
Dir.glob(SinatraApp::Application.models_dir.join("*.rb")).each{ |f| require f }
SinatraApp::Application.apis.each do |version, api|
  Dir.glob(SinatraApp::Application.models_dir.join(api[:models], "*.rb")).each{ |f| require f } if api[:models].present?
end

module SinatraApp
  class BaseController < Sinatra::Base
    # Required to share settings between class and instances
    class << self
      def global_settings
        SinatraApp::Application.global_settings || {}
      end
    end
    delegate :global_settings, to: "self.class"

    configure :development do
      set :static, true
      set :public_dir, SinatraApp::Application.public_dir
      register Sinatra::Reloader
      Dir.glob(SinatraApp::Application.models_dir.join("*.rb")).each{ |f| also_reload f }
    end

    configure :production do
      set :static, false
    end

    before { env["rack.errors"] = SinatraApp::Application.log_file }

    if SinatraApp::Application.api_routing
      before { set_api_version }
    end

    after { ActiveRecord::Base.connection.close }


    set :views, Proc.new { get_views_for_controller(self) }
    set :erb, layout_options: { views: Proc.new { get_layouts } }
    set :markdown, layout_options: { views: Proc.new { get_layouts } }
    set :layout, Proc.new { !request.xhr? }
    set :cors_api, SinatraApp::Application.cors_api

    helpers do
      def find_template(views, name, engine, &block)
        p [engine, name, views]
        views = views.call if views.is_a?(Proc)
        p [engine, name, views]
        Array(views).each { |v| super(v, name, engine, &block) }
      end
    end

    private

    def self.get_views_for_controller(controller)
      dir = controller.to_s.demodulize.gsub(/Controller\z/, '').downcase
      views = [ SinatraApp::Application.views.join(dir) ]
      if SinatraApp::Application.api_routing && SinatraApp::Application.apis[global_settings[:api_version]][:views].present?
        api_dir_path = SinatraApp::Application.views.join(SinatraApp::Application.apis[global_settings[:api_version]][:views], dir)
        views.unshift(api_dir_path) if File.directory?(api_dir_path)
      end
      views.uniq
    end

    def self.get_layouts
      layouts = [ SinatraApp::Application.views.join(SinatraApp::Application.layouts_dir_name) ]
      if SinatraApp::Application.api_routing && SinatraApp::Application.apis[global_settings[:api_version]][:views].present?
        api_layout_path = SinatraApp::Application.views.join(SinatraApp::Application.apis[global_settings[:api_version]][:views], SinatraApp::Application.layouts_dir_name)
        layouts.unshift(api_layout_path) if File.directory?(api_layout_path)
      end
      layouts.uniq
    end

    def set_api_version
      if SinatraApp::Application.api_versions.include?(params['api_version'])
        SinatraApp::Application.global_settings[:api_version] = params['api_version']
      else
        SinatraApp::Application.global_settings[:api_version] = SinatraApp::Application.default_api_version
      end
    end
  end
end

module SinatraApp
  class Base < BaseController
    # To use multi route, we need to register it
    register Sinatra::MultiRoute

    configure { use Rack::CommonLogger, SinatraApp::Application.logger }

    if SinatraApp::Application.api_routing
      klass_without_api = Class.new SinatraApp::BaseController do
        controller_filenames = Dir.glob(SinatraApp::Application.controllers_dir.join("*.rb")).sort
        controller_filenames.each { |f| require f }
        controller_filenames.each { |f| f = File.basename(f); use eval(f.gsub(/#{File.extname(f)}\z/, '').classify) }
      end

      SinatraApp::Application.apis.each do |version, api|
        if api[:controllers].present?
          klass_with_api = Class.new SinatraApp::BaseController do
            controller_filenames = Dir.glob(SinatraApp::Application.controllers_dir.join(api[:controllers], "*.rb")).sort
            controller_filenames.each { |f| require f }
            controller_filenames.each { |f| use eval(f.gsub(/\A#{SinatraApp::Application.controllers_dir.to_s}\//, '').gsub(/\.rb\z/, '').classify) }
          end

          route :get, :put, :post, :patch, :delete, :options, '/*' do
            pass unless global_settings[:api_version] == version
            if env["PATH_INFO"] =~ /\A#{api[:path_prefix]}/
              klass_with_api.call(env.merge({"PATH_INFO" => env["PATH_INFO"].gsub(/\A#{api[:path_prefix]}/, '') }))
            else
              klass_without_api.call(env)
            end
          end
        end
      end
    else
      controller_filenames = Dir.glob(SinatraApp::Application.controllers_dir.join("*.rb")).sort
      controller_filenames.each { |f| require f }
      controller_filenames.each { |f| f = File.basename(f); use eval(f.gsub(/#{File.extname(f)}\z/, '').classify) }
    end
  end
end
