class ExerciseController < Sinatra::Base
  extend GlobalAppSettings
  include Helpers

  self.apply_global_settings

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/exercises" do
  
  end

  get "/exercises/new" do

  end

  post "/exercises" do
    
  end

  get "/exercises/:id/edit" do
    
  end

  patch "/exercises/:id" do
    
  end

  delete "/exercises/:id" do
    
  end

end