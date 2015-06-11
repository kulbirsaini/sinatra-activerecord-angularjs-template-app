require File.expand_path('../boot', __FILE__)
require 'sinatra/base'
require 'sinatra/reloader'
require 'active_support/all'
require 'logger'
require 'yaml'

# Remove template engine you don't like/want.
require 'tilt/erb'
require 'tilt/rdiscount'

module SinatraApp
  class Application < Sinatra::Application
    cattr_accessor :connection_info, :db_dir, :migrations_dir, :groups, :models_dir, :controllers_dir, :lib_dir, :log_dir, :log_filepath, :log_file, :logger, :cors_api

    Sinatra::Application.environment = ENV['RACK_ENV'].present? ? ENV['RACK_ENV'].to_sym : :development
    Sinatra::Application.root =  Pathname.new(File.dirname(File.expand_path('../', __FILE__)))

    env_config_file = ENV['SINATRA_CONFIG'] || 'config/sinatra_app.yml'
    env_config = YAML::load(open(root.join(env_config_file)).read).symbolize_keys[environment].symbolize_keys

    Sinatra::Application.views = root.join(env_config[:views_dir])
    Sinatra::Application.public_dir = root.join(env_config[:public_dir])
    @@connection_info =  YAML::load(File.open(root.join(env_config[:database_config]))).symbolize_keys
    @@db_dir = root.join(env_config[:db_dir])
    @@migrations_dir = db_dir.join('migrate')
    @@models_dir = root.join(env_config[:models_dir])
    @@controllers_dir = root.join(env_config[:controllers_dir])
    @@lib_dir = root.join(env_config[:lib_dir])
    @@log_dir = root.join(env_config[:log_dir])
    @@log_filepath = log_dir.join("#{environment}.log")
    @@groups = [ :default ] << environment
    @@cors_api = !!env_config[:enable_cors_api]

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

module SinatraApp
  class BaseController < Sinatra::Base
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

    after { ActiveRecord::Base.connection.close }

    set :views, Proc.new { SinatraApp::Application.views.join(self.to_s.gsub(/Controller\z/, '').downcase) }
    set :erb, layout_options: { views: SinatraApp::Application.views.join('layouts') }
    set :markdown, layout_options: { views: SinatraApp::Application.views.join('layouts') }
    set :layout, Proc.new { !request.xhr? }
    set :cors_api, SinatraApp::Application.cors_api
  end

  class Base < BaseController
    configure do
      use Rack::CommonLogger, SinatraApp::Application.logger
    end

    controller_filenames = Dir.glob(SinatraApp::Application.controllers_dir.join("*.rb")).sort
    controller_filenames.each { |f| require f }
    controller_filenames.each { |f| f = File.basename(f); use eval(f.gsub(/#{File.extname(f)}\z/, '').classify) }
  end
end
