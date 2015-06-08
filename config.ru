require File.expand_path('../config/environment', __FILE__)

def app
  SinatraApp::Application
end

run SinatraApp::Application
