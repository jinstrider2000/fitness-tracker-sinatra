class User < ActiveRecord::Base
    include Slugifiable
    has_many :foods
    has_many :exercises
    has_secure_password
    validates_presence_of :username, :name, :daily_calorie_goal
end