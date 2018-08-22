class AddStakingToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :staking, :boolean
  end
end
