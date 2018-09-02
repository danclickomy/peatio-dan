# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :referral do
    url "MyString"
    visitor_count 1
    register_count 1
    active false
    identity nil
  end
end
