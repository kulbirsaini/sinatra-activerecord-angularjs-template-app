require File.expand_path('../config/environment', __FILE__)

def app
  SinatraApp::Base
end

run SinatraApp::Base
