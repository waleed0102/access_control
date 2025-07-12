class CreateAgeGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :age_groups do |t|
      t.string :name
      t.integer :min_age
      t.integer :max_age
      t.text :description
      t.text :participation_rules

      t.timestamps
    end
  end
end
