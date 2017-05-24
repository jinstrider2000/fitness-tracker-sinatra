class UserController < Sinatra::Base

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/signup" do
    if logged_in?
      @title = "Fitness Tracker - Sign Up"
      @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :'users/new'
    else
      redirect "/users/#{current_user.slug}"
    end
  end

  post "/signup" do
    if User.find_by(username: params[:user][:username])
      flash[:username_error] = "* That username is already taken."
    end

    unless params[:user][:daily_calorie_goal] =~ /\A\d+\Z/
      flash[:calorie_error] = "* Enter a numerical value for your daily calorie goal."
    end
    
    if params[:profile_img] && !(params[:profile_img][:type] =~ /image/)
      flash[:image_error] = "* Please upload an image."
    end

    if flash.has?(:username_error) || flash.has?(:calorie_error) || flash.has?(:image_error)
      redirect '/signup'
    else
      temp_user = User.create(params[:user])
      if temp_user.valid?
        temp_user.create_slug
        profile_pic_dir = File.join(Dir.pwd,"public","images","users","#{temp_user.id}")
        Dir.mkdir(profile_pic_dir) unless Dir.exist?(profile_pic_dir)
        if params[:profile_img]
          file_ext = File.extname(params[:profile_img][:filename])
          File.open("public/images/users/#{temp_user.id}/#{temp_user.id}_profilepic_1_#{file_ext}", mode: "w", binmode: true){|file| file.write(File.read(params[:profile_img][:tempfile], binmode: true))}
        else
          File.open("public/images/users/#{temp_user.id}/#{temp_user.id}_profilepic_1_.png", mode: "w", binmode: true){|file| file.write(File.read("public/images/users/generic/profile_pic.png", binmode: true))}
        end
        redirect "/login"
      else
        flash[:invalid_error] = "* Please fill out all fields."
        redirect '/signup'
      end
    end
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
          profile_pic_array = profile_pic_dir(user)
          profile_pic_dir_w_file = profile_pic_array[0]
          new_pic_instance_num = profile_pic_array[1].split("_")[2].to_i + 1
          File.delete(profile_pic_dir_w_file)
          file_ext = File.extname(params[:profile_img][:filename])
          File.open("public/images/users/#{user.id}/#{user.id}_profilepic_#{new_pic_instance_num}_#{file_ext}", mode: "w", binmode: true){|file| file.write(File.read(params[:profile_img][:tempfile], binmode: true))}
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