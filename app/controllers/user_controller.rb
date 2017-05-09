class UserController < Sinatra::Base
  extend GlobalAppSettings

  self.apply_global_settings

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/users/:slug" do
    @user = User.find_by(slug: params[:slug])
    if !!@user
      @title = viewing_own_profile_while_logged_in?(@user) ? "My Stats" : "#{first_name(@user.name)}'s Stats"
      @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :'users/show'
    else
      flash[:error] = "The user you are looking for doesn't exist"
      erb :error
    end
    
  end

  get "/users/:slug/edit" do
    @user = User.find_by(slug: params[:slug])
    if logged_in? && viewing_own_profile_while_logged_in?(@user)
      @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :'users/edit'
    else
      flash[:error] = "Your request cannot be completed"
      erb :error
    end
  end

  get "/users/:slug/exercises" do
    # Update soon...
     @user = User.find_by(slug: params[:slug])
    if !!@user
      @title = viewing_own_profile_while_logged_in?(@user) ? "My Stats" : "#{first_name(@user.name)}'s Stats"
      @nav = {:exercise => {:status => "active"}, :nutrition => {:status => ""}}
      erb :'exercises/index'
    else
      flash[:error] = "The user you are looking for doesn't exist"
      erb :error
    end
  end
  
  get "/users/:slug/foods" do
    # Update soon...
     @user = User.find_by(slug: params[:slug])
    if !!@user
      @title = viewing_own_profile_while_logged_in?(@user) ? "My Stats" : "#{first_name(@user.name)}'s Stats"
      @nav = {:exercise => {:status => ""}, :nutrition => {:status => "active"}}
      erb :'foods/index'
    else
      flash[:error] = "The user you are looking for doesn't exist"
      erb :error
    end
  end

  patch "/users/:slug" do
    redirect "/users/#{current_user.slug}"
  end

end