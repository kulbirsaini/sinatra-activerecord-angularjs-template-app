## Sinatra ActiveRecord Angularjs Template App

[Sinatra](http://www.sinatrarb.com/) &amp; ActiveRecord (backend) + [Angularjs](https://angularjs.org/) (frontend) template app for getting started.


## Sinatra Configuration

* Database config file: `config/database.yml`

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

###### Generate a new ActiveRecord model with migration

```bash
$ ./script/generate_model book name:string author:string amazon_url:string
```

###### Run Angular App

```bash
$ npm start
```

Available at [http://localhost:3000/](http://localhost:3000/)


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
