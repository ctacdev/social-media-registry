# == Schema Information
#
# Table name: agencies
#
#  id                         :integer          not null, primary key
#  name                       :string(255)
#  created_at                 :datetime
#  updated_at                 :datetime
#  shortname                  :string(255)
#  info_url                   :string(255)
#  mongo_id                   :string(255)
#  parent_mongo_id            :string(255)
#  parent_id                  :integer
#  draft_outlet_count         :integer          default(0)
#  draft_mobile_app_count     :integer          default(0)
#  published_outlet_count     :integer          default(0)
#  published_mobile_app_count :integer          default(0)
#  draft_gallery_count        :integer          default(0)
#  published_gallery_count    :integer          default(0)
#  api_id                     :integer
#

class Agency < ApplicationRecord
  #attr_accessible :name, :shortname, :info_url, :agency_contact_ids
  
  # each agency has social media outlets
  has_many :sponsorships, dependent: :destroy
  has_many :outlets, :through => :sponsorships
  
  # each agency has defined contacts
  has_many :agency_contacts

  # each agency has mobile applications
  has_many :mobile_app_agencies, dependent: :destroy
  has_many :mobile_apps, :through => :mobile_app_agencies
  
  has_many :gallery_agencies, dependent: :destroy
  has_many :galleries, :through => :gallery_agencies

  #each agency has users tied to them (not necessarily contacts)
  has_many :users
  
  # Ecah agency can have parents/children agencies
  belongs_to :parent, :class_name => "Agency" 
  has_many :children, :foreign_key => "parent_id", :class_name => "Agency"

  validates :name, :presence => true
  # validates :shortname, :presence => true
  
  paginates_per 100

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |agency|
        csv << agency.attributes.values_at(*column_names)
      end
    end
  end


  def update_counters
    self.draft_gallery_count = galleries.where("draft_id IS NULL").count
    self.published_gallery_count = galleries.where("draft_id IS NOT NULL").count


    self.draft_outlet_count = outlets.where("draft_id IS NULL").count
    self.published_outlet_count = outlets.where("draft_id IS NOT NULL").count

    self.draft_mobile_app_count = mobile_apps.where("draft_id IS NULL").count
    self.published_mobile_app_count = mobile_apps.where("draft_id IS NOT NULL").count
  end

  def contact_emails(options = {})
    agency_contacts.where("email != ?", options[:excluding]).map do |contact|
      contact.email
    end
  end

  def name_and_social_media_count
    "#{name} (#{published_outlet_count})"
  end
  
  def name_and_mobile_count
    "#{name} (#{published_mobile_app_count})"
  end

end
