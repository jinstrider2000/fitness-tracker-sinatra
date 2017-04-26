class ApplicationController < Sinatra::Base
  extend GlobalAppSettings
  include Helpers

  self.apply_global_settings

  get "/" do
    erb :index
  end

  get "/signup" do
    
  end

  post "/signup" do

  end

  get "/login" do

  end

  post "/login" do
    
  end

  get "/logout" do
    
  end

end