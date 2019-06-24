# == Schema Information
#
# Table name: outlet_official_tags
#
#  id              :integer          not null, primary key
#  outlet_id       :integer
#  official_tag_id :integer
#

class OutletOfficialTag < ApplicationRecord
  belongs_to :outlet
  belongs_to :official_tag

  after_save :update_counter_cache
  after_destroy :update_counter_cache
  
  def update_counter_cache
    self.official_tag.draft_outlet_count = self.official_tag.outlets.where("draft_id IS NULL").count
    self.official_tag.published_outlet_count = self.official_tag.outlets.where("draft_id IS NOT NULL").count
    self.official_tag.save
  end

end
