class User < ActiveRecord::Base
    include Slugifiable
    has_many :foods
    has_many :exercises
    has_secure_password
    validates_presence_of :username, :name, :daily_calorie_goal
    validates :username, uniqueness: true
    validates :daily_calorie_goal, numericality: {greater_than_or_equal_to: 1}

    def first_name
      self.name.split(" ")[0]
    end
end