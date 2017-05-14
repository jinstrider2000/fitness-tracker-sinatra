class ExerciseController < Sinatra::Base
  extend FitnessTracker::GlobalAppSettings

  self.apply_global_settings

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/exercises/new" do
    @logged_in = logged_in?
    if @logged_in
      @current_user = current_user
      @title = "Fitness Tracker - Add Exercise"
      @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
      erb :'exercises/new'
    else
      redirect '/'
    end
  end

  get "/exercises/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
    @title = "Fitness Tracker - Exercise"
    @exercise = Exercise.find_by(id: params[:id])
    if @exercise
      erb :'exercises/show'
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "The exercise stat you are looking for doesn't exist."
      erb :error
    end
  end

  post "/exercises" do
    @logged_in = logged_in?
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
    if @logged_in
      @current_user = current_user
      unless params[:exercise][:calories_burned] =~ /\A\d+\Z/
        flash[:exercise_create_error] = "* Enter a numerical value for your calorie intake."
        redirect '/exercises/new'
      end
      new_achievement = Achievement.create(activity: @current_user.exercises.create(params[:exercise]))
      if new_achievement.valid?
        redirect "/users/#{@current_user.slug}/exercises"
      else
        flash[:exercise_create_error] = "* Please fill out all fields."
        redirect '/exercises/new'
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      erb :error
    end
  end

  get "/exercises/:id/edit" do
    @exercise = Exercise.find_by(id: params[:id])
    @logged_in = logged_in?
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}

    if @logged_in && editing_own_activity(@exercise)
      @current_user = current_user
      @title = "Fitness Tracker - Edit Exercise"
      erb :'exercises/edit'
    else
      redirect "/exercises/#{params[:id]}"
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
    if @logged_in && editing_own_activity(exercise)
      exercise.update(params[:exercise])
      if exercise.valid?
        redirect "/exercises/#{params[:id]}"
      else
        flash[:exercise_edit_error] = "* Please fill out all fields."
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      erb :error
    end
  end

  delete "/exercises/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => "active"}, :nutrition => {:status => ""}}
    exercise = Exercise.find_by(id: params[:id])
    if @logged_in && editing_own_activity(exercise)
      exercise.destroy
      redirect "/users/#{@current_user.slug}/exercises"
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      erb :error
    end
  end

end