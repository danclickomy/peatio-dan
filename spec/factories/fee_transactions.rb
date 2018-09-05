# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :fee_transaction do
    from_account 1
    to_account 1
    original_transaction_sum "9.99"
    fee_sum "9.99"
    reason "MyString"
  end
end
