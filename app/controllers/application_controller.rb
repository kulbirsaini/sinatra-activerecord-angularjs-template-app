class ApplicationController < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    Dir.glob(SinatraApp::Application.models_dir.join("*.rb")).each{ |f| also_reload f }
  end

  before do
    content_type 'application/json'
    params.merge!(JSON.parse(request.body.read)) rescue nil if request.request_method == "POST"
    headers \
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
      'Access-Control-Request-Method': '*',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept'
  end

  after do
    ActiveRecord::Base.connection.close
  end

  options '/*' do
    halt 200
  end

  get '/' do
    content_type 'text/html'
    Markdown.new(File.read(SinatraApp::Application.root.join('Readme.md'))).to_html
  end
end
