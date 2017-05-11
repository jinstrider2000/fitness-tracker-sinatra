class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :name
      t.string :password_digest
      t.integer :daily_calorie_goal
      t.string :slug
      t.timestamps
    end
  end
end