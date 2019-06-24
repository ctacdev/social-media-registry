# == Schema Information
#
# Table name: official_tags
#
#  id                         :integer          not null, primary key
#  tag_text                   :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  draft_gallery_count        :integer          default(0)
#  draft_mobile_app_count     :integer          default(0)
#  draft_outlet_count         :integer          default(0)
#  published_gallery_count    :integer          default(0)
#  published_mobile_app_count :integer          default(0)
#  published_outlet_count     :integer          default(0)
#  tag_type                   :integer          default(0)
#

class OfficialTag < ApplicationRecord
  #attr_accessible :shortname, :tag_text
  
  validates :tag_text, :presence => true, :uniqueness => true

  enum tag_type: { category: 0, geographic: 1} # 0 will be the default, in this case, category

  has_many :outlet_official_tags, :dependent => :destroy
  has_many :outlets, through: :outlet_official_tags

  has_many :mobile_app_official_tags, :dependent => :destroy
  has_many :mobile_apps, through: :mobile_app_official_tags

  has_many :gallery_official_tags, :dependent => :destroy
  has_many :galleries, through: :gallery_official_tags
  
  def tag_text=(text)
    self[:tag_text] = text.downcase
  end

  def tag_link
    "<a href='javascript:add_tag(\"#{tag_text}\")'>#{tag_text}</a>"
  end

   
  def text_and_social_count
    "#{tag_text} (#{published_outlet_count})"
  end

  def text_and_mobile_count
    "#{tag_text} (#{published_mobile_app_count})"
  end
end
