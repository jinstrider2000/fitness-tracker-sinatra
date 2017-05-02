module GlobalAppSettings
    def apply_global_settings
        configure do
            set :views, 'app/views'
            set :public_folder, 'public'
            # set :sessions, true
            # set :session_secret, "fitness_tracker_efrain"
        end
    end
end