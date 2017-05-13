class Food < ActiveRecord::Base
    belongs_to :user
    has_many :achievements, as: :activity
    validates_presence_of :name, :calories
end