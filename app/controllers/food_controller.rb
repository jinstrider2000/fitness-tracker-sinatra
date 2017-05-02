class FoodController < Sinatra::Base
  extend GlobalAppSettings
  include Helpers

  self.apply_global_settings

	configure do
		set :method_override, true
    # use Rack::Flash, :sweep => true
	end

  get "/foods" do
  
  end

  get "/foods/new" do

  end

  post "/foods" do
    
  end

  get "/foods/:id/edit" do
    
  end

  patch "/foods/:id" do
    
  end

  delete "/foods/:id" do
    
  end

end