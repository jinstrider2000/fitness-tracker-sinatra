class User < ActiveRecord::Base
    extend Slugifiable::ClassMethods
    include Slugifiable::InstanceMethods
    has_many :foods
    has_many :exercises
    has_secure_password
    validates_presence_of :username, :name, :password, :daily_calorie_goal
end