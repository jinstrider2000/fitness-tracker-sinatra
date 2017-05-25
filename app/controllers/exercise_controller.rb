class ExerciseController < ApplicationController

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/exercises/users/:slug" do
    @user = User.find_by(slug: params[:slug])
    if @user
      if viewing_own_profile_while_logged_in?(@user)
        @main_heading = "My Exercise"
        @title = "Fitness Tracker - My Exercise"
      else
        @main_heading = "#{@user.first_name}'s Exercise"
        @title = "Fitness Tracker - #{@user.first_name}'s Exercise"
      end
      erb :'exercises/index'
    else
      display_err_page(404,"The user you are looking for doesn't exist.")
    end
  end

  get "/exercises/new" do
    if logged_in?
      @title = "Fitness Tracker - Add Exercise"
      erb :'exercises/new'
    else
      redirect '/'
    end
  end

  post "/exercises" do
    if logged_in?
      new_exercise = current_user.exercises.new(params[:exercise])
      unless new_exercise.valid?
        flash[:exercise_create_error] = new_exercise.errors.details[:calories_burned].any?{|detail| detail[:error] == :not_a_number} ? "* Enter a numerical value for your calories consumed." : "* Please fill out all fields."
        redirect '/exercises/new'
      else
        new_exercise.save
        new_achievement = Achievement.create(activity: new_exercise)
        redirect "/exercises/users/#{current_user.slug}"
      end
    else
      display_err_page(403, "Your request cannot be completed.")
    end
  end

  get "/exercises/:id" do
    @title = "Fitness Tracker - Exercise"
    @exercise = Exercise.find_by(id: params[:id])
    if @exercise
      erb :'exercises/show'
    else
      display_err_page(404, "The exercise stat you are looking for doesn't exist.")
    end
  end

  get "/exercises/:id/edit" do
    @exercise = Exercise.find_by(id: params[:id])
    if viewing_own_activity?(@exercise)
      @title = "Fitness Tracker - Edit Exercise"
      erb :'exercises/edit'
    else
      display_err_page(403, "Your request cannot be completed.")
    end
  end

  patch "/exercises/:id" do
    exercise = Exercise.find_by(id: params[:id])
    if viewing_own_activity?(exercise)
      temp_ex = Exercise.new(params[:exercise])
      unless temp_ex.valid?
        flash[:exercise_edit_error] = temp_ex.errors.details[:calories_burned].any?{|detail| detail[:error] == :not_a_number} ? "* Enter a numerical value for your calories consumed." : "* Please fill out all fields."
        redirect "/exercises/#{params[:id]}/edit"
      else
        exercise.update(params[:exercise])
        redirect "/exercises/users/#{current_user.slug}"
      end
    else
      display_err_page(403, "Your request cannot be completed.")
    end
  end

  delete "/exercises/:id" do
    exercise = Exercise.find_by(id: params[:id])
    if viewing_own_activity?(exercise)
      Achievement.find_by(activity: exercise).destroy
      exercise.destroy
      redirect_dir = referred_by_recent_activity? ? "/recent-activity" : "/exercises/users/#{current_user.slug}" 
      redirect redirect_dir
    else
      display_err_page(403, "Your request cannot be completed.")
    end
  end

end