class AddTimestamps < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :created_on, :datetime
    add_column :users, :updated_on, :datetime
    add_column :foods, :created_on, :datetime
    add_column :foods, :updated_on, :datetime
    add_column :exercises, :created_on, :datetime
    add_column :exercises, :updated_on, :datetime
  end
end
