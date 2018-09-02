class CreateIdentityReferrers < ActiveRecord::Migration
  def change
    create_table :identity_referrers do |t|
      t.references :identity, index: true
      t.integer :my_ref_id
      t.integer :referred_by_identity

      t.timestamps
    end
  end
end
