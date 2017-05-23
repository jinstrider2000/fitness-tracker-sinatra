class ApplicationController < Sinatra::Base

  configure do
    helpers FitnessTracker::Helpers
    set :environment, :development
    set :views, 'app/views'
    set :sessions, true
    set :session_secret, "fitness_tracker_efrain"
  end

  get "/" do
    if logged_in?
      redirect "/recent-activity"
    else
      @title = "Fitness Tracker"
      @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :landing
    end
  end

  get "/recent-activity" do
    @nav = {:activity => {:status => "active"}, :exercise => {:status => ""}, :nutrition => {:status => ""}}
    logged_in?
    
    @title = "Fitness Tracker - Recent Achievements"
    erb :recent_activity
  end

  get "/signup" do
    @logged_in = logged_in?
    if !@logged_in
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

  get "/login" do
    @logged_in = logged_in?
    if @logged_in
      redirect "/users/#{current_user.slug}"
    else
      @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}
      @title = "Fitness Tracker - Sign In"
      erb :login
    end
  end

  post "/login" do
    @logged_in = logged_in?
    if !@logged_in
      user = User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:id] = user.id
        redirect "/users/#{current_user.slug}"
      else
        flash[:not_found_error] = "* Username or password incorrect"
        redirect '/login'
      end 
    else
      @current_user = current_user
      @title = "Fitness Tracker - Error"
      @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

  get "/logout" do
    session.clear
    redirect '/'
  end

end