class ReferralController < ApplicationController
  def show
    @referral = Referral.find_by_identity_id(Identity.find_by_email(current_user.email))
  end
end
