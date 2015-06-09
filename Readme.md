## Sinatra ActiveRecord Angularjs Template App

[Sinatra](http://www.sinatrarb.com/) &amp; ActiveRecord (backend) + [Angularjs](https://angularjs.org/) (frontend) template app for getting started.


## Sinatra Configuration

* Database config file: [`config/database.yml`](https://github.com/kulbirsaini/sinatra-activerecord-angularjs-template-app/blob/master/config/database.yml)

```ruby
default: &default
  adapter: sqlite3
  pool: 10
  timeout: 1000

development:
  <<: *default
  database: db/development.sqlite3

test:
  <<: *default
  database: db/test.sqlite3

production:
  <<: *default
  database: db/production.sqlite3
```

* Setting environment

```bash
export APP_ENV=production
```

## Rake Tasks

```bash
$ rake -T
rake db:connect       # Connect to database
rake db:create        # Create database
rake db:drop          # Drop database
rake db:fake_connect  # Establiish fake connection to database
rake db:migrate       # Migrate database
rake db:migrate:down  # One migration down
rake db:migrate:up    # One migration up
rake db:rollback      # Rollback migrations
rake db:seed          # Seed database
$
```


## Grunt Tasks


###### Compile SCSS files

```bash
$ grunt sass
```

###### Minify CSS files generated after compiling SCSS files

```bash
$ grunt cssmin
```

###### Copy bootstrap fonts to fonts directory

```bash
$ grunt copy
```

###### Minify all JS files to `public/assets/minjs/application.min.js`

```bash
$ grunt uglify
```

###### Watch SCSS &amp; JS files for changes

```bash
$ grunt watch
```

###### Do all the above tasks

```bash
$ grunt
Running "copy:main" (copy) task
Copied 5 files

Running "sass:dist" (sass) task

Running "cssmin:dist" (cssmin) task
>> 1 file created. 280.81 kB → 138.29 kB

Running "uglify:js" (uglify) task
>> 1 file created.

Running "watch" task
Waiting...
```


## How To Run?

###### Bundle

```bash
$ bundle install
```

###### Run Sinatra App

```bash
$ ./script/server
```

Available at [http://localhost:4567/](http://localhost:4567/)

###### Ruby console with Sinatra environment

```bash
$ ./script/console
```

###### Generate a new resource (including ActiveRecord model, controller and migration)

```bash
$ ./script/generate_resource book name:string author:string published:boolean
Generating model       /home/saini/sinatra-template/app/models/book.rb
Generating migration   /home/saini/sinatra-template/db/migrate/20150609083344_create_books.rb
Generating controller  /home/saini/sinatra-template/app/controllers/books_controller.rb
$
$ ./script/generate_resource -h
Usage:
  ./script/generate_resource resource_name field1:type1 field2:type2

Example:
  ./script/generate_resource book name:string author:string released:boolean

Options:
  -h, [--help]       # Print this help message
  -f, [--force]      # Overwrite files that already exist
  --skip-model       # Skip generating model file
  --skip-migration   # Skip generating migration file
  --skip-controller  # Skip generating controller file
```

###### Run Angular App

```bash
$ npm start
```

Available at [http://localhost:3000/](http://localhost:3000/)


## Deploy Configuration

Deploy config file: [`config/deploy.rb`](https://github.com/kulbirsaini/sinatra-activerecord-angularjs-template-app/blob/master/config/deploy.rb)

```ruby
# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'myapp.example.com'
set :repo_url, 'https://github.com/kulbirsaini/sinatra-activerecord-angularjs-template-app.git'
set :branch, :master
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty
set :log_level, :info
set :linked_files, fetch(:linked_files, []).push('tmp/restart.txt', 'db/production.sqlite3')
set :linked_dirs, fetch(:linked_dirs, []).push('log', 'node_modules', 'public/bower_components')
set :keep_releases, 1
set :bundle_path, -> { shared_path.join('bundle') }

namespace :deploy do
  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      execute :touch, current_path.join('tmp/restart.txt')
    end
  end

  desc 'Install dependencies'
  task :bower_and_npm_install do
    on roles(:app), in: :sequence, wait: 10 do
      within release_path do
        execute :npm, "install"
        execute :bower, "install"
      end
    end
  end

  desc 'Grunt tasks'
  task :grunt do
    on roles(:app), in: :sequence, wait: 10 do
      within release_path do
        execute :bundle, "exec grunt copy"
        execute :bundle, "exec grunt sass"
        execute :bundle, "exec grunt cssmin"
        execute :bundle, "exec grunt uglify"
      end
    end
  end

  after :published, :bower_and_npm_install
  after :bower_and_npm_install, :grunt
  after :finished, :restart
end
```

Production stage config file: [`config/deploy/production.rb`](https://github.com/kulbirsaini/sinatra-activerecord-angularjs-template-app/blob/master/config/deploy/production.rb)

```ruby
set :application, 'myapp.example.com'
set :rvm_type, :user
set :rvm_ruby_version, '2.2.2'
set :stage, :production
set :default_env, { 'APP_ENV': 'production' }
role :web, "#{fetch(:application)}"
role :app, "#{fetch(:application)}"
role :db,  "#{fetch(:application)}", :primary => true
set :deploy_to, "/path/to/domains/domains/#{fetch(:application)}"

server "#{fetch(:application)}", user: 'saini', roles: %w{web app}
```

## Deploy Using Capistrano

*NOTE:* Must be run in app root directory.

```bash
$ cap production deploy
```


## <a name="about_me"></a>About Me
[Kulbir Saini](http://saini.co.in/),
Senior Developer / Programmer,
Hyderabad, India

## Contact Me
Kulbir Saini - contact [AT] saini.co.in / [@_kulbir](https://twitter.com/_kulbir)

## <a name="license"></a>License
Copyright (c) 2015 Kulbir Saini

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
