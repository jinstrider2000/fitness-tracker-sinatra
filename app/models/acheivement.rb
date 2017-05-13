class Achievement < ActiveRecord::Base
  belongs_to :activity, polymorphic: true
  validates_presence_of :activity
end