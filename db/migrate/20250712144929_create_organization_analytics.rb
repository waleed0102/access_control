class CreateOrganizationAnalytics < ActiveRecord::Migration[5.2]
  def change
    create_table :organization_analytics do |t|
      t.integer :organization_id
      t.integer :total_members
      t.integer :active_members
      t.text :age_distribution
      t.text :role_distribution
      t.datetime :last_updated

      t.timestamps
    end
  end
end
