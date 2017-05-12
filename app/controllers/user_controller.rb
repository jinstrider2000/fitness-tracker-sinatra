class UserController < Sinatra::Base
  extend FitnessTracker::GlobalAppSettings

  self.apply_global_settings

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/users/:slug" do
    @user = User.find_by(slug: params[:slug])
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}

    if @user
      @viewing_own_profile_while_logged_in = viewing_own_profile_while_logged_in?(@user,@current_user)
      if @viewing_own_profile_while_logged_in
        @main_heading = "Welcome #{first_name(@user.name)}!"
        @title = "My Stats"
      else
        @main_heading = "#{@user.name}"
        @title = "#{@user.name}'s Stats"
      end
      erb :'users/show'
    else
      flash[:error] = "The user you are looking for doesn't exist."
      erb :error
    end
    
  end

  get "/users/:slug/edit" do
    @user = User.find_by(slug: params[:slug])
    @logged_in = logged_in?
    @current_user = current_user
    @viewing_own_profile_while_logged_in = viewing_own_profile_while_logged_in?(@user,@current_user)
    @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}

    if @logged_in && @viewing_own_profile_while_logged_in
      erb :'users/edit'
    else
      flash[:error] = "Your request cannot be completed."
      erb :error
    end
  end

  get "/users/:slug/exercises" do
    @user = User.find_by(slug: params[:slug])
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}

    if @user
      @viewing_own_profile_while_logged_in = viewing_own_profile_while_logged_in?(@user,@current_user)
      if @viewing_own_profile_while_logged_in
        @nav[:exercise][:status] = "active"
        @main_heading = "My Exercise"
        @title = "Fitness Tracker - My Exercise"
      else
        @main_heading = "#{first_name(@user.name)}'s Exercise"
        @title = "Fitness Tracker - #{first_name(@user.name)}'s Exercise"
      end
      erb :'exercises/index'
    else
      flash[:error] = "The user you are looking for doesn't exist."
      erb :error
    end
  end
  
  get "/users/:slug/foods" do
    @user = User.find_by(slug: params[:slug])
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}

    if @user
      @viewing_own_profile_while_logged_in = viewing_own_profile_while_logged_in?(@user,@current_user)
      if @viewing_own_profile_while_logged_in
        @nav[:nutrition][:status] = "active"
        @main_heading = "My Meals"
        @title = "Fitness Tracker - My Meals"
      else
        @main_heading = "#{first_name(@user.name)}'s Meals"
        @title = "Fitness Tracker - #{first_name(@user.name)}'s Meals"
      end
      erb :'foods/index'
    else
      flash[:error] = "The user you are looking for doesn't exist."
      erb :error
    end
  end

  patch "/users/:slug" do
    user = User.find_by(slug: params[:slug])
    if viewing_own_profile_while_logged_in?(user,current_user)
      params.delete(:password) if params[:user][:password] == ""
      user.update(params[:user])
      user.create_slug
      if params[:profile_img]
        File.delete(profile_pic_dir(user))
        file_ext = File.extname(params[:profile_img][:filename])
        File.open("public/images/users/#{user.id}/profile_pic#{file_ext}", mode: "w", binmode: true){|file| file.write(File.read(params[:profile_img][:tempfile], binmode: true))}
      end
      redirect "/users/#{user.slug}"
    else
      flash[:error] = "Sorry, your request cannot be completed."
      erb :error
    end
  end

end