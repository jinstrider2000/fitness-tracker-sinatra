class FoodController < ApplicationController

	configure do
		set :method_override, true
    use Rack::Flash, :sweep => true
	end

  get "/foods/users/:slug" do
    @user = User.find_by(slug: params[:slug])
    if @user
      if viewing_own_profile_while_logged_in?(@user)
        @main_heading = "My Meals"
        @title = "Fitness Tracker - My Meals"
      else
        @main_heading = "#{@user.first_name}'s Meals"
        @title = "Fitness Tracker - #{@user.first_name}'s Meals"
      end
      erb :'foods/index'
    else
      display_err_page(404, "The user you are looking for doesn't exist.")
    end
  end

  get "/foods/new" do
    if logged_in?
      @title = "Fitness Tracker - Add Meal"
      erb :'foods/new'
    else
      redirect '/'
    end
  end

  post "/foods" do
    if logged_in?
      new_food = current_user.foods.new(params[:food])
      unless new_food.valid?
        flash[:food_create_error] = new_food.errors.details[:calories].any?{|detail| detail[:error] == :not_a_number} ? "* Enter a numerical value for your calorie intake." : "* Please fill out all fields."
        redirect '/foods/new'
      else
        new_food.save
        new_achievement = Achievement.create(activity: new_food)
        redirect "/foods/users/#{current_user.slug}"
      end
    else
      display_err_page(403, "Your request cannot be completed.")
    end
  end

  get "/foods/:id" do
    @title = "Fitness Tracker - Meal"
    @food = Food.find_by(id: params[:id])
    if @food
      erb :'foods/show'
    else
      display_err_page(404, "The food stat you are looking for doesn't exist.")
    end
  end

  get "/foods/:id/edit" do
    @food = Food.find_by(id: params[:id])
    if viewing_own_activity?(@food)
      @title = "Fitness Tracker - Edit Meal"
      erb :'foods/edit'
    else
      display_err_page(403, "Your request cannot be completed.")
    end
  end

  patch "/foods/:id" do
    food = Food.find_by(id: params[:id])
    if viewing_own_activity?(food)
      temp_fd = Food.new(params[:food])
      unless temp_fd.valid?
        flash[:food_edit_error] = new_food.errors.details[:calories].any?{|detail| detail[:error] == :not_a_number} ? "* Enter a numerical value for your calorie intake." : "* Please fill out all fields."
        redirect "/foods/#{params[:id]}/edit"
      else
        food.update(params[:food])
        redirect "/foods/users/#{current_user.slug}"
      end
    else
      display_err_page(403, "Your request cannot be completed.")
    end
  end

  delete "/foods/:id" do
    food = Food.find_by(id: params[:id])
    if viewing_own_activity?(food)
      Achievement.find_by(activity: food).destroy
      food.destroy
      redirect_dir = referred_by_recent_activity? ? "/recent-activity" : "/foods/users/#{current_user.slug}"
      redirect redirect_dir
    else
      display_err_page(403, "Your request cannot be completed.")
    end
  end

end