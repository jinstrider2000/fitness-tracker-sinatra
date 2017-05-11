module FitnessTracker
    module GlobalAppSettings
        def apply_global_settings
            configure do
                helpers FitnessTracker::Helpers
                set :environment, :development
                set :views, 'app/views'
                set :sessions, true
                set :session_secret, "fitness_tracker_efrain"
            end
        end
    end
end
