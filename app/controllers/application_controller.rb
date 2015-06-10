class ApplicationController < SinatraApp::BaseController
  before do
    params.merge!(JSON.parse(request.body.read)) rescue nil if request.request_method == "POST"
    # Uncomment lines below to expose CORS API
    #headers \
    #  'Access-Control-Allow-Origin' => '*',
    #  'Access-Control-Allow-Methods' => 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
    #  'Access-Control-Request-Method' => '*',
    #  'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept'
  end

  options '/*' do
    halt 200
  end

  get '/' do
    markdown File.read(SinatraApp::Application.root.join('Readme.md'))
  end
end
