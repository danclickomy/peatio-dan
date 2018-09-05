class Identity < OmniAuth::Identity::Models::ActiveRecord
  auth_key :email
  attr_accessor :old_password

  MAX_LOGIN_ATTEMPTS = 5

  has_one :referral
  has_one :identity_referrer

  validates :email, presence: true, uniqueness: true, email: true
  validates :password, presence: true, length: {minimum: 6, maximum: 64}
  validates :password_confirmation, presence: true, length: {minimum: 6, maximum: 64}

  before_validation :sanitize

  after_save :create_identity_referrer

  def increment_retry_count
    self.retry_count = (retry_count || 0) + 1
  end

  def too_many_failed_login_attempts
    retry_count.present? && retry_count >= MAX_LOGIN_ATTEMPTS
  end


  private

  def sanitize
    self.email.try(:downcase!)
  end

  def create_identity_referrer
    referrer_identity_id = find_identity_by_my_ref_id($my_ref_id)
    new_identity_referrer = IdentityReferrer.new(identity_id: self.id, referred_by_identity: referrer_identity_id)
    new_identity_referrer.save

    create_referral
  end


  def find_identity_by_my_ref_id(my_ref_id)
    referrer_identity_id = IdentityReferrer.find_by_my_ref_id(my_ref_id).nil? ? 0 : IdentityReferrer.find_by_my_ref_id(my_ref_id).identity_id
    return referrer_identity_id
  end


  def create_referral
    referral_url = "192.168.108.132:3000/signup/?ref=" + self.identity_referrer.my_ref_id.to_s
    new_referral = Referral.new(url: referral_url, active: true, identity_id: self.id)
    new_referral.save
  end

end
