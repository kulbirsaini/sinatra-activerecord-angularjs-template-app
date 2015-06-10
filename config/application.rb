require File.expand_path('../boot', __FILE__)
require 'sinatra/base'
require 'sinatra/reloader'
require 'active_support/all'
require 'logger'
require 'yaml'
require 'tilt/erb'

module SinatraApp
  class Application < Sinatra::Application
    cattr_accessor :connection_info, :migrations_dir, :groups, :models_dir, :controllers_dir, :lib_dir, :log_dir, :log_filepath, :log_file, :logger

    Sinatra::Application.environment = ENV['APP_ENV'].present? ? ENV['APP_ENV'].to_sym : :development
    Sinatra::Application.root =  Pathname.new(File.dirname(File.expand_path('../', __FILE__)))
    Sinatra::Application.views = root.join('app/views')
    Sinatra::Application.public_dir = root.join('public')
    @@connection_info =  YAML::load(File.open(root.join('config/database.yml'))).symbolize_keys
    @@migrations_dir = root.join('db/migrate')
    @@models_dir = root.join('app/models')
    @@controllers_dir = root.join('app/controllers')
    @@lib_dir = root.join('lib')
    @@log_dir = root.join('log')
    @@log_filepath = log_dir.join("#{environment}.log")
    @@groups = [ :default ] << environment

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
    set :layout, Proc.new { !request.xhr? }
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
