class ReferralController < ApplicationController
  def show
    @current_identity = Identity.find_by_email(current_user.email)

    @referral = Referral.find_by_identity_id(@current_identity)
    @users_referred_by_me = IdentityReferrer.where(:referred_by_identity => @current_identity.id)
    @register_count = @users_referred_by_me.count
  end
end
