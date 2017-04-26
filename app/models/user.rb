class User < ActiveRecord::Base
    has_many :foods
    has_many :exercises
    has_secure_password
    validates_presence_of :username, :name, :password, :daily_calorie_goal
end