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
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}

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
      status 404
      body(erb :error)
    end
    
  end

  get "/users/:slug/edit" do
    @user = User.find_by(slug: params[:slug])
    @logged_in = logged_in?
    @current_user = current_user
    @viewing_own_profile_while_logged_in = viewing_own_profile_while_logged_in?(@user,@current_user)
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}

    if @logged_in && @viewing_own_profile_while_logged_in
      @title = "Fitness Tracker - Edit Profile"
      erb :'users/edit'
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

  patch "/users/:slug" do
    user = User.find_by(slug: params[:slug])
    @logged_in = logged_in?
    @current_user = current_user
    if viewing_own_profile_while_logged_in?(user,@current_user)
      params[:user].delete(:password) if params[:user][:password] == ""
      user.update(params[:user])
      if user.valid?
        user.create_slug
        if params[:profile_img]
          File.delete(profile_pic_dir(user))
          file_ext = File.extname(params[:profile_img][:filename])
          File.open("public/images/users/#{user.id}/profile_pic#{file_ext}", mode: "w", binmode: true){|file| file.write(File.read(params[:profile_img][:tempfile], binmode: true))}
        end
        redirect "/users/#{user.slug}"
      else
        flash[:user_edit_error] = "* Please fill out all required fields"
        redirect "/users/#{params[:slug]}/edit"
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

end