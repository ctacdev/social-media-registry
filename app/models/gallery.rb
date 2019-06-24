# == Schema Information
#
# Table name: galleries
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#  draft_id          :integer
#  short_description :text(65535)
#  long_description  :text(65535)
#  status            :integer          default(0)
#

class Gallery < ApplicationRecord
	 #handles logging of activity
	include PublicActivity::Model
  include Notifications

	tracked owner: Proc.new{ |controller, model| controller.current_user }

  scope :by_agency, lambda {|id| joins(:agencies).where("agencies.id" => id) }
  scope :api, -> { where("draft_id IS NOT NULL") }

  enum status: { under_review: 0, published: 1, archived: 2, publish_requested: 3 }

  # Galleries have a relationship to themselvs
  # The "published" outlet will have a draft_id pointing to its parent
  # The "draft" outlet will not have a draft_id field
  # This will allow easy querying on the public / admin portion of the application
  has_one :published, class_name: "Gallery", foreign_key: "draft_id", dependent: :destroy
  belongs_to :draft, class_name: "Gallery", foreign_key: "draft_id"

	has_many :gallery_users, dependent: :destroy
	has_many :users, through: :gallery_users

	has_many :gallery_official_tags, dependent: :destroy
  has_many :official_tags, :through => :gallery_official_tags

  has_many :gallery_agencies, dependent: :destroy
  has_many :agencies, :through => :gallery_agencies

  has_many :gallery_items, -> { order "item_order ASC"}, dependent: :destroy
  has_many :mobile_apps, :through => :gallery_items, :source => :item, :source_type => "MobileApp"
  has_many :outlets, :through => :gallery_items, :source => :item, :source_type => "Outlet"

  validates :name, :presence => true
  validates :agencies, :length => { :minimum => 1, :message => "have at least one sponsoring agency" }
  validates :users, :length => { :minimum => 1, :message => "have at least one contact" }

  def published_gallery_items
    self.gallery_items.where(status: 1)
  end

  def published_mobile_apps
    MobileApp.where("draft_id IN (?)",self.mobile_app_ids)
  end

  def published_outlets
    Outlet.where("draft_id IN (?)", self.outlet_ids)
  end


  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << (column_names + ["agencies" ,"contacts" ,"tags"])

      self.includes(:agencies,:users,:official_tags).each do |outlet|
        csv << (outlet.attributes.values_at(*column_names) + [outlet.agencies.map(&:name).join("|") ,outlet.users.map(&:email).join("|"),outlet.official_tags.map(&:tag_text).join("|")])
      end
    end
  end

  # This handles a json serialized format from the administrative end.
  # It is to allowed ordering of lists in the forms
  # Please be careful if messing with this, its senssitive
  def gallery_items_ol=(list)
    if list
    	gallery_list = JSON.parse(list)[0]
      if gallery_list.count != 0
        mobile_ids = []
        social_ids = []
        gallery_items.destroy_all
      	gallery_list.each_with_index do |item,index|
      		if ["MobileApp","Outlet"].include? item["class"]
      			if item["class"].constantize.find(item["id"])
              gallery_items <<  GalleryItem.find_or_create_by({
    		  			item_id: item["id"],
    		  			item_type: item["class"],
                item_order: index
    		  		})
    		  	else
              # This error occurs if an invalid id is provided, generally should only be found by devs
    		  		self.errors.add(:base, "Couldn't find item to add to gallery")
    		  	end
    	  	else
            # This error would require either a developer or something trying to do wrong to reach
    	  		self.errors.add(:base, "A gallery item was of the wrong class")
    	  	end
      	end
      else
        GalleryItem.where(gallery_id: id).destroy_all
      end
      # cleanup all records not found in the list this time. required due to way we are handling
      # data serialization
    else
    	GalleryItem.where(gallery_id: id).destroy_all
    end
  end


  def published!
    Gallery.public_activity_off
    self.status = Gallery.statuses[:published]
    self.published.destroy! if self.published
    new_gallery = Gallery.new({
      name: self.name,
      short_description: self.short_description,
      long_description: self.long_description,
      agency_ids: self.agency_ids || [],
      user_ids: self.user_ids || [],
      official_tag_ids: self.official_tag_ids || [],
      status: self.status,
      draft_id: self.id
    })
    self.gallery_items.each do |mav|
     new_gallery.gallery_items << GalleryItem.create!(item_id: mav.item_id, item_type: mav.item_type)
    end
    new_gallery.save(validate: false)
    self.save(validate: false)
    MobileApp.public_activity_on
    self.create_activity :published
  end

  def archived!
    Gallery.public_activity_off
    self.status = Gallery.statuses[:archived]
    self.published.destroy! if self.published
    self.save(validate: false)
    Gallery.public_activity_on
    self.create_activity :archived
  end

  def publish_requested!
    Gallery.public_activity_off
    self.status = Gallery.statuses[:publish_requested]
    self.save(validate: false)
    Gallery.public_activity_on
    self.create_activity :publish_requested
  end

  def archive_requested!
    Gallery.public_activity_off
    self.status = Gallery.statuses[:archive_requested]
    self.save(validate: false)
    Gallery.public_activity_on
    self.create_activity :archive_requested
  end

	def tag_tokens=(ids)
    current_ids = []
    ids.split(",").each do |id|
      current_ids << OfficialTag.find_or_create_by(tag_text: id).id
    end
    self.official_tag_ids = current_ids
  end

  def agency_tokens=(ids)
    self.agency_ids = ids.split(',')
  end

  def user_tokens=(ids)
    self.user_ids = ids.split(',')
  end
end
