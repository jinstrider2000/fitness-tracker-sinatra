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
      display_err_page(403,"Your request cannot be completed.")
    end
  end

  get "/logout" do
    session.clear
    redirect '/'
  end

end