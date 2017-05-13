class Activity < ActiveRecord::Base

  belongs_to :interface, polymorphic: true

end