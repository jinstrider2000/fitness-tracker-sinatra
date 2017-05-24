class ExerciseController < ApplicationController

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/exercises/users/:slug" do
    @user = User.find_by(slug: params[:slug])
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}

    if @user
      if viewing_own_profile_while_logged_in?(@user)
        @nav[:exercise][:status] = "active"
        @main_heading = "My Exercise"
        @title = "Fitness Tracker - My Exercise"
      else
        @main_heading = "#{first_name(@user.name)}'s Exercise"
        @title = "Fitness Tracker - #{first_name(@user.name)}'s Exercise"
      end
      erb :'exercises/index'
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "The user you are looking for doesn't exist."
      status 404
      body(erb :error)
    end
  end

  get "/exercises/new" do
    if logged_in?
      @title = "Fitness Tracker - Add Exercise"
      @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
      erb :'exercises/new'
    else
      redirect '/'
    end
  end

  post "/exercises" do
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
    if logged_in?
      
      redirect '/exercises/new'
      new_exercise = @current_user.exercises.new(params[:exercise])
      unless new_exercise.valid?
        if new_exercise.errors.messages[:calories_burned]
          
        end
      else
        
      end
      flash[:exercise_create_error] = "* Enter a numerical value for your calorie intake."
      new_achievement = Achievement.create(activity: @current_user.exercises.create(params[:exercise]))
      if new_achievement.valid?
        redirect "/exercises/users/#{@current_user.slug}"
      else
        flash[:exercise_create_error] = "* Please fill out all fields."
        redirect '/exercises/new'
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

  get "/exercises/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
    @title = "Fitness Tracker - Exercise"
    exercise = Exercise.find_by(id: params[:id])
    viewing_own_activity = viewing_own_activity?(exercise)
    if exercise
      erb(:'exercises/show', :locals => {:exercise => exercise, :viewing_own_activity => viewing_own_activity})
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "The exercise stat you are looking for doesn't exist."
      status 404
      body(erb :error)
    end
  end

  get "/exercises/:id/edit" do
    exercise = Exercise.find_by(id: params[:id])
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
    viewing_own_activity = viewing_own_activity?(exercise)

    if @logged_in && viewing_own_activity
      @title = "Fitness Tracker - Edit Exercise"
      erb(:'exercises/edit', :locals => {:exercise => exercise, :viewing_own_activity => viewing_own_activity})
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

  patch "/exercises/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
    unless params[:exercise][:calories_burned] =~ /\A\d+\Z/
      flash[:exercise_edit_error] = "* Enter a numerical value for your calorie intake."
      redirect "/exercises/#{params[:id]}/edit"
    end
    exercise = Exercise.find_by(id: params[:id])
    if @logged_in && viewing_own_activity?(exercise)
      exercise.update(params[:exercise])
      if exercise.valid? 
        redirect "/exercises/users/#{current_user.slug}"
      else
        flash[:exercise_edit_error] = "* Please fill out all fields."
        redirect "/exercises/#{params[:id]}/edit"
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

  delete "/exercises/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
    exercise = Exercise.find_by(id: params[:id])
    if @logged_in && viewing_own_activity?(exercise)
      Achievement.find_by(activity: exercise).destroy
      exercise.destroy
      redirect_dir = referred_by_recent_activity? ? "/recent-activity" : "/exercises/users/#{current_user.slug}" 
      redirect redirect_dir
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

end