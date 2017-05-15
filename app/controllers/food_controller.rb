class FoodController < Sinatra::Base
  extend FitnessTracker::GlobalAppSettings

  self.apply_global_settings

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "foods/users/:slug" do
    @user = User.find_by(slug: params[:slug])
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}

    if @user
      @viewing_own_profile_while_logged_in = viewing_own_profile_while_logged_in?(@user,@current_user)
      if @viewing_own_profile_while_logged_in
        @nav[:nutrition][:status] = "active"
        @main_heading = "My Meals"
        @title = "Fitness Tracker - My Meals"
      else
        @main_heading = "#{first_name(@user.name)}'s Meals"
        @title = "Fitness Tracker - #{first_name(@user.name)}'s Meals"
      end
      erb :'foods/index'
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "The user you are looking for doesn't exist."
      status 404
      body(erb :error)
    end
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
        redirect "/foods/users/#{@current_user.slug}"
      else
        flash[:food_create_error] = "* Please fill out all fields."
        redirect '/foods/new'
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

  get "/foods/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}
    @title = "Fitness Tracker - Meal"
    @food = Food.find_by(id: params[:id])
    @viewing_own_activity = viewing_own_activity?(@food)
    if @food
      erb :'foods/show'
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "The food stat you are looking for doesn't exist."
      status 404
      body(erb :error)
    end
  end

  get "/foods/:id/edit" do
    @food = Food.find_by(id: params[:id])
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}
    @viewing_own_activity = viewing_own_activity?(@food)

    if @logged_in && @viewing_own_activity
      @title = "Fitness Tracker - Edit Meal"
      erb :'foods/edit'
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
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
    if @logged_in && viewing_own_activity?(food)
      food.update(params[:food])
      if food.valid?
        redirect_dir = referred_by_recent_activity? ? "/recent-activity" : "/foods/users/#{current_user.slug}"
        redirect redirect_dir
      else
        flash[:food_edit_error] = "* Please fill out all fields."
        redirect "/foods/#{params[:id]}/edit"
      end
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

  delete "/foods/:id" do
    @logged_in = logged_in?
    @current_user = current_user
    @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => "active"}}
    food = Food.find_by(id: params[:id])
    if @logged_in && viewing_own_activity?(food)
      food.destroy
      redirect_dir = referred_by_recent_activity? ? "/recent-activity" : "/foods/users/#{current_user.slug}"
      redirect redirect_dir
    else
      @title = "Fitness Tracker - Error"
      flash[:error] = "Your request cannot be completed."
      status 403
      body(erb :error)
    end
  end

end