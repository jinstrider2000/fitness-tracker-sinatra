class UserController < ApplicationController

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/signup" do
    unless logged_in?
      @title = "Fitness Tracker - Sign Up"
      erb :'users/new'
    else
      redirect "/users/#{current_user.slug}"
    end
  end

  post "/signup" do
    new_user = User.new(params[:user])
    unless new_user.valid?
      flash[:username_error] = "* That username is already taken." if new_user.errors.details[:username].any?{|detail| detail[:error] == :taken}
      flash[:calorie_error] = "* Invalid number for your daily calorie goal." if new_user.errors.details[:daily_calorie_goal].any?{|detail| detail[:error] == :not_a_number || detail[:error] == :greater_than_or_equal_to || detail[:error] == :blank}
      flash[:image_error] = "* Please upload an image." if FitnessTracker::ImageSaver.image_present_and_valid?(params)
      flash[:invalid_error] = "* Please fill out all fields." if new_user.errors.details[:username].any?{|detail| detail[:error]==:blank} || new_user.errors.details[:password].any?{|detail| detail[:error]==:blank} || new_user.errors.details[:name].any?{|detail| detail[:error]==:blank}
      redirect '/signup'
    else
      new_user.save
      new_user.create_slug
      FitnessTracker::ImageSaver.save_profile_pic(new_user.id, params)
      redirect "/login"
    end
  end

  get "/users/:slug" do
    @user = User.find_by(slug: params[:slug])
    if @user
      if viewing_own_profile_while_logged_in?(@user)
        @main_heading = "Welcome #{@user.first_name}!"
        @title = "My Stats"
      else
        @main_heading = "#{@user.name}"
        @title = "#{@user.name}'s Stats"
      end
      erb :'users/show'
    else
      display_err_page(404,"The user you are looking for doesn't exist.")
    end
  end

  get "/users/:slug/edit" do
    user = User.find_by(slug: params[:slug])
    if viewing_own_profile_while_logged_in?(user)
      @title = "Fitness Tracker - Edit Profile"
      erb :'users/edit'
    else
      display_err_page(403,"Your request cannot be completed.")
    end
  end

  patch "/users/:slug" do
    user = User.find_by(slug: params[:slug])
    if viewing_own_profile_while_logged_in?(user)
      params[:user].delete(:password) if params[:user][:password] == ""
      user.update(params[:user])
      unless user.valid?
        flash[:user_edit_error] = user.errors.details[:username].any?{|detail| detail[:error] == :taken} ?  "* That username is already taken." : "* Please fill out all fields correctly"
        redirect "/users/#{params[:slug]}/edit"
      else
        user.create_slug
        FitnessTracker::ImageSaver.update_profile_pic(user.id, params)
        redirect "/users/#{user.slug}"
      end
    else
      display_err_page(403,"Your request cannot be completed.")
    end
  end

end