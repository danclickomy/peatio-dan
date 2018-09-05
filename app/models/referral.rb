class Referral < ActiveRecord::Base
  belongs_to :identity
  before_create :make_counts_zero

  private
  def make_counts_zero
    self.visitor_count = 0
  end
end
