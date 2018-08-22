class AddStakingFeeToDeposits < ActiveRecord::Migration
  def change
    add_column :deposits, :staking_fee, :decimal, precision: 5, scale: 3     
  end
end
