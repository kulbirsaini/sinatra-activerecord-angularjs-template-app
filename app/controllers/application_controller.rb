class ApplicationController < SinatraApp::BaseController
  before do
    params.merge!(JSON.parse(request.body.read)) rescue nil if request.request_method == "POST"
    if settings.cors_api
      headers \
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
        'Access-Control-Request-Method' => '*',
        'Access-Control-Allow-Headers' => 'Origin, Content-Type, Accept, Accept-Language'
    end
  end

  options '/*' do
    halt 200
  end

  get '/' do
    markdown :"#{SinatraApp::Application.root.join('Readme').to_s}", views: ''
  end
end
