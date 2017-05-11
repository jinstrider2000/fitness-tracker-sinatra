class CreateExercises < ActiveRecord::Migration[5.0]
  def change
    create_table :exercises do |t|
      t.string :name
      t.integer :calories_burned
      t.integer :user_id
      t.timestamps
    end
  end
end


