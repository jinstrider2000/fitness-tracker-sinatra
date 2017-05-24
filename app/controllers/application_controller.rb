class ApplicationController < Sinatra::Base

  configure do
    helpers FitnessTracker::Helpers
    set :environment, :development
    set :views, 'app/views'
    set :sessions, true
    set :session_secret, "fitness_tracker_efrain"
  end

  get "/" do
    if logged_in?
      redirect "/recent-activity"
    else
      @title = "Fitness Tracker"
      @nav = {:activity => {:status => ""}, :exercise => {:status => ""}, :nutrition => {:status => ""}}
      erb :landing
    end
  end

  get "/recent-activity" do
    @nav = {:activity => {:status => "active"}, :exercise => {:status => ""}, :nutrition => {:status => ""}}
    @title = "Fitness Tracker - Recent Achievements"
    erb :recent_activity
  end

end