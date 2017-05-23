class Food < ActiveRecord::Base
    belongs_to :user
    has_one :achievement, as: :activity
    validates_presence_of :name, :calories
    validates :calories, numericality: {greater_than_or_equal_to: 0}
end