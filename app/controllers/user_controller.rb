class UserController < Sinatra::Base
  extend GlobalAppSettings
  include Helpers

  self.apply_global_settings

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/users/:slug" do
    binding.pry
    @title = "#{first_name(current_user.name)}'s Stats"
    @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
    erb :'users/show'
  end

  get "/users/:slug/edit" do
    @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
    erb :'users/edit'
  end

  patch "/users/:slug" do
    redirect "/users/#{current_user.slug}"
  end

end