class Exercise < ActiveRecord::Base
    belongs_to :user
    has_one :achievement, as: :activity
    validates_presence_of :name, :calories_burned
    validates :calories_burned, numericality: {greater_than_or_equal_to: 1}
end