class CreateScores < ActiveRecord::Migration[7.0]
  def change
    create_table :scores do |t|
      t.string :name, null: false, default: ""
      t.integer :time_spent, default: 0, null: false
      t.integer :clicks_count, default: 0, null: false
      t.json :data
      t.float :best_score, default: 0, null: false
      t.timestamps
    end
  end
end
