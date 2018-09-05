class DeleteRegisterCountFromReferrals < ActiveRecord::Migration
  def change
    remove_column :referrals, :register_count
  end
end
