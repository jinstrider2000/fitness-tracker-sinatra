class UserController < Sinatra::Base
  extend GlobalAppSettings
  include Helpers

  self.apply_global_settings

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/users/new" do

  end

  post "/users" do
    
  end

  get "/users/:slug" do

  end

  get "/users/:slug/edit" do
    
  end

  patch "/users/:slug" do
    
  end

  delete "/users/:slug" do
    
  end

end