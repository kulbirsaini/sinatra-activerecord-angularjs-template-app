require File.expand_path('../boot', __FILE__)
require 'sinatra/base'
require 'facets/class/cattr'
require 'facets/kernel/blank'
require 'facets/hash/symbolize_keys'
require 'yaml'

module SinatraApp
  class Application < Sinatra::Application
    cattr_accessor :connection_info, :migrations_dir, :groups, :models_dir, :controllers_dir, :lib_dir

    Sinatra::Application.environment = ENV['APP_ENV'].present? ? ENV['APP_ENV'].to_sym : :development
    Sinatra::Application.root =  Pathname.new(File.dirname(File.expand_path('../', __FILE__)))
    Sinatra::Application.views = root.join('app/views')
    Sinatra::Application.public_dir = root.join('public')
    @@connection_info =  YAML::load(File.open(root.join('config/database.yml'))).symbolize_keys
    @@migrations_dir = root.join('db/migrate')
    @@models_dir = root.join('app/models')
    @@controllers_dir = root.join('app/controllers')
    @@lib_dir = root.join('lib')
    @@groups = [ :default ] << environment

    def initialize(options = {})
      super
      ActiveRecord::Base.establish_connection(self.class.connection_info[self.class.environment])
    end
  end
end

Bundler.require(*SinatraApp::Application.groups)
require 'sinatra/reloader'

Dir.glob(SinatraApp::Application.lib_dir.join('*.rb')).each{ |f| require f }
Dir.glob(SinatraApp::Application.lib_dir.join('tasks/*.rake')).each{ |f| import f }
Dir.glob(SinatraApp::Application.models_dir.join("*.rb")).each{ |f| require f }
controller_filenames = Dir.glob(SinatraApp::Application.controllers_dir.join("*.rb")).sort
controller_filenames.each { |f| require f }
controller_filenames.each { |f| f = File.basename(f); use eval(f.gsub(/#{File.extname(f)}\z/, '').classify) }
