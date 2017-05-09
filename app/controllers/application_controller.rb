class ApplicationController < Sinatra::Base
  extend GlobalAppSettings

  self.apply_global_settings

  get "/" do
    if logged_in?
      redirect "/recent-activity"
    else
      @title = "Fitness Tracker"
      @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :landing
    end
  end

  get "/recent-activity" do

  end

  get "/signup" do
    @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
    erb :'users/new'
  end

  post "/signup" do
    if !!User.find_by(username: params[:user][:username])
      # binding.pry
      flash[:username_error] = "That username is already taken."
    end

    unless params[:user][:daily_calorie_goal] =~ /\A\d+\Z/
      # binding.pry
      flash[:calorie_error] = "Enter a numerical value for your daily calorie goal."
    end

    if params[:profile_img] && !params[:profile_img][:type] =~ /image/
      # binding.pry
      flash[:image_error] = "Please upload an image."
    end

    if flash.has?(:username_error) || flash.has?(:calorie_error) || flash.has?(:image_error)
      # binding.pry
      redirect '/signup'
    else
      temp_user = User.create(params[:user])
      temp_user.create_slug
      Dir.mkdir(File.join(Dir.pwd,"public","images","users","#{temp_user.id}"))
      if !!params[:profile_img]
        file_ext = /image\/(.+)/.match(params[:profile_img][:type])[1]
        File.open("public/images/#{temp_user.id}/profile_pic.#{file_ext}", mode: "w", binmode: true){|file| file.write(File.read(params[:profile_img][:tempfile], binmode: true))}
        redirect "/users/#{temp_user.slug}"
      else
        File.open("public/images/users/#{temp_user.id}/profile_pic.png", mode: "w", binmode: true){|file| file.write(File.read("public/images/users/generic/profile_pic.png", binmode: true))}
      end
      # session[:id] = temp_user.id if !logged_in?
      # binding.pry
      redirect "/recent-activity"
    end
  end

  get "/login" do
    if logged_in?
      redirect "/users/#{current_user.slug}"
    else
      @nav = {:exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :login
    end
  end

  post "/login" do
    user = User.find_by(username: params[:username])
    if !!user && !!user.authenticate(params[:password])
      session[:id] = user.id
      redirect "/users/#{current_user.slug}"
    else
      flash[:error] = "Username or password incorrect"
      redirect '/login'
    end
  end

  get "/logout" do
    session.clear
    redirect '/'
  end

end