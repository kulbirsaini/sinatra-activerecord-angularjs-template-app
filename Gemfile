source 'https://rubygems.org'

gem 'sinatra'
# Have to force require nil otherwise Rakefile wont work
gem 'sinatra-contrib', require: false
# Ruby facets for additional functionality
gem 'facets', require: false
# Replace with DB of your choice
gem 'sqlite3'
# ActiveRecord from rails
gem 'activerecord', require: 'active_record'
# For rendering awesome JSON
gem 'jbuilder'
# Rake tasks
gem 'rake'
# Replace with server of your choice
gem 'thin'
# For nicer output in console
gem 'hirb'
# For parsing Markdown files
gem 'rdiscount'

# Auto deploment with capistrano
group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end
