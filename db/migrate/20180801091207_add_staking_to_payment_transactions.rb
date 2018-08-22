class AddStakingToPaymentTransactions < ActiveRecord::Migration
  def change
    add_column :payment_transactions, :staking, :boolean
  end
end
