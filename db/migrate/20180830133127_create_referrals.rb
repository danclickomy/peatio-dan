class CreateReferrals < ActiveRecord::Migration
  def change
    create_table :referrals do |t|
      t.string :url
      t.integer :visitor_count
      t.integer :register_count
      t.boolean :active
      t.references :identity, index: true

      t.timestamps
    end
  end
end
