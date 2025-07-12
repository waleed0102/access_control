class CreateParticipationSpaces < ActiveRecord::Migration[5.2]
  def change
    create_table :participation_spaces do |t|
      t.string :name
      t.text :description
      t.integer :age_group_id
      t.integer :organization_id
      t.text :access_rules
      t.boolean :is_active

      t.timestamps
    end
  end
end
