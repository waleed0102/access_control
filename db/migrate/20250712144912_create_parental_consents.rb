class CreateParentalConsents < ActiveRecord::Migration[5.2]
  def change
    create_table :parental_consents do |t|
      t.integer :user_id
      t.string :parent_email
      t.string :parent_name
      t.boolean :consent_given
      t.datetime :consent_date
      t.boolean :terms_accepted

      t.timestamps
    end
  end
end
