class CreateFeeTransactions < ActiveRecord::Migration
  def change
    create_table :fee_transactions do |t|
      t.integer :from_account
      t.integer :to_account
      t.decimal :original_transaction_sum, precision: 15, scale: 4
      t.decimal :fee_sum, precision: 15, scale: 4
      t.string :reason

      t.timestamps
    end
  end
end
