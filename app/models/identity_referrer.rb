class IdentityReferrer < ActiveRecord::Base
  belongs_to :identity
  before_create :update_my_ref_id

  private

  def update_my_ref_id
    maximum_my_ref_id = IdentityReferrer.maximum(:my_ref_id) || 0
    new_my_ref_id = maximum_my_ref_id + 3
    self.my_ref_id = new_my_ref_id
  end
end
