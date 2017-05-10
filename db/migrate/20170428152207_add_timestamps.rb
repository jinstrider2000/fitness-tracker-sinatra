class AddTimestamps < ActiveRecord::Migration
  def change
    add_column :users, :created_at, :datetime
    add_column :users, :updated_at, :datetime
    add_column :foods, :created_at, :datetime
    add_column :foods, :updated_at, :datetime
    add_column :exercises, :created_at, :datetime
    add_column :exercises, :updated_at, :datetime
  end
end
