class FoodController < Sinatra::Base
  extend FitnessTracker::GlobalAppSettings

  self.apply_global_settings

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

    get "/foods/new" do
    @logged_in = logged_in?
    if @logged_in
      @current_user = current_user
      @title = "Fitness Tracker - Add Meal"
      @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}
      erb :'foods/new'
    else
      redirect '/'
    end
  end

  get "/foods/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}
    @title = "Fitness Tracker - Meal"
    @food = Food.find_by(id: params[:id])
    if @food
      erb :'foods/show'
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "The food stat you are looking for doesn't exist."
      erb :error
    end
  end

  post "/foods" do
    @logged_in = logged_in?
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}
    if @logged_in
      @current_user = current_user
      unless params[:food][:calories] =~ /\A\d+\Z/
        flash[:food_create_error] = "* Enter a numerical value for your calorie intake."
        redirect '/foods/new'
      end
      new_achievement = Achievement.create(activity: @current_user.foods.create(params[:food]))
      if new_achievement.valid?
        redirect "/users/#{@current_user.slug}/foods"
      else
        flash[:food_create_error] = "* Please fill out all fields."
        redirect '/foods/new'
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      erb :error
    end
  end

  get "/foods/:id/edit" do
    @food = Food.find_by(id: params[:id])
    @logged_in = logged_in?
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}

    if @logged_in && editing_own_activity(@food)
      @current_user = current_user
      @title = "Fitness Tracker - Edit Meal"
      erb :'foods/edit'
    else
      redirect "/foods/#{params[:id]}"
    end
  end

  patch "/foods/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}
    unless params[:food][:calories] =~ /\A\d+\Z/
      flash[:food_edit_error] = "* Enter a numerical value for your calorie intake."
      redirect "/foods/#{params[:id]}/edit"
    end
    food = Food.find_by(id: params[:id])
    if @logged_in && editing_own_activity(food)
      food.update(params[:food])
      if food.valid?
        redirect "/foods/#{params[:id]}"
      else
        flash[:food_edit_error] = "* Please fill out all fields."
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      erb :error
    end
  end

  delete "/foods/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}
    food = Food.find_by(id: params[:id])
    if @logged_in && editing_own_activity(food)
      food.destroy
      redirect "/users/#{@current_user.slug}/foods"
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      erb :error
    end
  end

end