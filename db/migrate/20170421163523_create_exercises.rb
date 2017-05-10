class CreateExercises < ActiveRecord::Migration
  def change
    create_table :exercises do |t|
      t.string :name
      t.integer :calories_burned
      t.integer :user_id
    end
  end
end


