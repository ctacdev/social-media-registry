# == Schema Information
#
# Table name: mobile_app_official_tags
#
#  id              :integer          not null, primary key
#  mobile_app_id   :integer
#  official_tag_id :integer
#

class MobileAppOfficialTag < ApplicationRecord
  belongs_to :mobile_app
  belongs_to :official_tag

  after_save :update_counter_cache
  after_destroy :update_counter_cache
  
  def update_counter_cache
    self.official_tag.draft_mobile_app_count = self.official_tag.mobile_apps.where("draft_id IS NULL").count
    self.official_tag.published_mobile_app_count = self.official_tag.mobile_apps.where("draft_id IS NOT NULL").count
    self.official_tag.save
  end
end