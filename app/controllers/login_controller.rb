class LoginController < ApplicationController

	get "/login" do 
    if logged_in?
      redirect "/users/#{current_user.slug}"
    else
      @title = "Fitness Tracker - Sign In"
      erb :login
    end
  end

  post "/login" do
    if !logged_in?
      user = User.find_by(username: params[:username])
      if user && user.authenticate(params[:password])
        session[:id] = user.id
        redirect "/users/#{current_user.slug}"
      else
        flash[:not_found_error] = "* Username or password incorrect"
        redirect '/login'
      end 
    else
      @title = "Fitness Tracker - Error"
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