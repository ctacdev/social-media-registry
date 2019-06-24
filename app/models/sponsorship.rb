# == Schema Information
#
# Table name: sponsorships
#
#  id         :integer          not null, primary key
#  outlet_id  :integer
#  agency_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class Sponsorship < ApplicationRecord
  #attr_accessible :agency_id, :outlet_id

  belongs_to :outlet
  belongs_to :agency

  after_save :update_counter_cache
  after_destroy :update_counter_cache
  
  def update_counter_cache
    if self.agency
      self.agency.draft_outlet_count = self.agency.outlets.where("draft_id IS NULL").count
      self.agency.published_outlet_count = self.agency.outlets.where("draft_id IS NOT NULL").count
      self.agency.save
    end
  end
end
