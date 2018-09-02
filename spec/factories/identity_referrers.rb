# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :identity_referrer do
    identity nil
    my_ref_id 1
    referred_by_identity 1
  end
end
