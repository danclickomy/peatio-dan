class AddStakingFeeToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :staking_fee, :decimal, precision: 5, scale: 3
  end
end
