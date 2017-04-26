class Exercise < ActiveRecord::Base
    belongs_to :user
    validates_presence_of :name, :calories_burned
end