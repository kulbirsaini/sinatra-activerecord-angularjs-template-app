set :application, 'myapp.example.com'
set :rvm_type, :user
set :rvm_ruby_version, '2.2.2'
set :stage, :production
set :default_env, { 'RACK_ENV': 'production' }
role :web, "#{fetch(:application)}"
role :app, "#{fetch(:application)}"
role :db,  "#{fetch(:application)}", :primary => true
set :deploy_to, "/path/to/domains/domains/#{fetch(:application)}"

server "#{fetch(:application)}", user: 'saini', roles: %w{web app}
