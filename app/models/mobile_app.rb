# == Schema Information
#
# Table name: mobile_apps
#
#  id                :integer          not null, primary key
#  name              :string(255)
#  short_description :text(65535)
#  long_description  :text(65535)
#  icon_url          :text(65535)
#  language          :string(255)
#  agency_id         :integer
#  status            :integer          default(0)
#  mongo_id          :string(255)
#  created_at        :datetime
#  updated_at        :datetime
#

class MobileApp < ActiveRecord::Base
  #handles logging of activity
  include PublicActivity::Model
  include Notifications
  include Elasticsearch::Model

  settings index: { number_of_shards: 1 } do
    mappings dynamic: 'false' do
      indexes :id, type: :integer
      indexes :name, analyzer: 'english'
      indexes :platform, analyzer: 'english'
      indexes :agencies, analyzer: 'english'
      indexes :contacts, analyzer: 'english'
      indexes :status, analyzer: 'english'
      indexes :updated_at, type: :date
    end
  end

  def as_indexed_json(options={})
    contact_list = []
    if self.try(:primary_contact).try(:email)
      contact_list << self.try(:primary_contact).try(:email)
    end
    if self.try(:secondary_contact).try(:email)
      contact_list << self.try(:secondary_contact).try(:email)
    end
    if self.users.count > 0
      contact_list << self.users.map(&:email)
    end

    agency_list = []
    if self.try(:primary_agency).try(:name)
      agency_list << self.try(:primary_agency).try(:name)
    end
    if self.try(:secondary_agency).try(:name)
      agency_list << self.try(:secondary_agency).try(:name)
    end
    if self.users.count > 0
      agency_list << self.agencies.map(&:name)
    end

    result = {
      id: self.id,
      name: name,
      agencies: agency_list.flatten.join(", "),
      contacts: contact_list.flatten.join(", "),
      platform: self.mobile_app_versions.map(&:platform).join(", "),
      status: self.status.humanize,
      updated_at: self.updated_at
    }
    result
  end

  tracked owner: Proc.new{ |controller, model| controller.current_user }

  scope :by_agency, lambda {|id| joins(:agencies).where("agencies.id" => id) }
  scope :api, -> { where(status: 1) }

  enum status: { under_review: 0, published: 1, archived: 2,
    publish_requested: 3, archive_requested: 4 }


  #attr_accessible :name, :shortname, :info_url, :agency_contact_ids
  acts_as_taggable

  has_many :gallery_items, as: :item, dependent: :destroy
  has_many :galleries, through: :gallery_items, source: "MobileApp"

  has_many :mobile_app_agencies, dependent: :destroy
  has_many :agencies, :through => :mobile_app_agencies

  has_many :mobile_app_users, dependent: :destroy
  has_many :users, :through => :mobile_app_users

  has_many :mobile_app_versions, :dependent => :destroy

  has_many :mobile_app_official_tags, dependent: :destroy
  has_many :official_tags, :through => :mobile_app_official_tags

  belongs_to :primary_contact, class_name: "User", foreign_key: "primary_contact_id"
  belongs_to :secondary_contact, class_name: "User", foreign_key: "secondary_contact_id"

  # validates :primary_contact, :presence => true
  # validates :secondary_contact, :presence => true


  belongs_to :primary_agency, class_name: "Agency", foreign_key: "primary_agency_id"
  belongs_to :secondary_agency, class_name: "Agency", foreign_key: "secondary_agency_id"

  # validates :primary_agency, :presence => true
  
  accepts_nested_attributes_for :mobile_app_versions, reject_if: :all_blank, allow_destroy: true

  validates :name, :presence => true
  validates :short_description, :presence => true
  validates :long_description, :presence => true
 
  validates :agencies, :length => { :minimum => 1, :message => "have at least one sponsoring agency" }
  validates :users, :length => { :minimum => 1, :message => "have at least one contact" }
  validates :mobile_app_versions, :length => { :minimum => 1, :message => "have at least one version of the product must be given." }



  def self.platform_counts
    joins(:mobile_app_versions).group(:platform).distinct("mobile_app_id, platform").count
  end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << (column_names + ["agencies" ,"contacts" ,"tags", "store_url", "platform", "version_number", "publish_date", "screenshot", "device", "average_rating", "number_of_ratings"])

      self.all.includes(:agencies,:users,:official_tags, :mobile_app_versions).each do |ma|
        versions = ma.mobile_app_versions
        if versions.count > 0
          versions.each do |version|
            csv << (ma.attributes.values_at(*column_names) + [
              ma.agencies.map(&:name).join("|") ,
              ma.users.map(&:email).join("|"),
              ma.official_tags.map(&:tag_text).join("|"),
              version.store_url,
              version.platform,
              version.version_number,
              version.publish_date ? version.publish_date.strftime("%B %e, %Y %H:%M") : "",
              version.screenshot,
              version.device,
              version.average_rating,
              version.number_of_ratings])
          end
        else
          csv << (ma.attributes.values_at(*column_names) + [ma.agencies.map(&:name).join("|") ,ma.users.map(&:email).join("|"), ma.official_tags.map(&:tag_text).join("|")])
        end
      end
    end
  end

  def self.export_csv(options={})
    CSV.generate(options) do |csv|
      csv << ["agencies" ,"platforms","platform_urls","name", "tags", "updated"]

      self.all.includes(:agencies,:users,:official_tags, :mobile_app_versions).each do |ma|
        versions = ma.mobile_app_versions
        csv << [ ma.agencies.map(&:name).join("|"),
          versions.map(&:platform).join("|"),
          versions.map(&:store_url).join("|"),
          ma.name,
          ma.official_tags.map(&:tag_text).join("|"),
          ma.updated_at ]
      end
    end
  end

  def self.es_search(params, sort_column, sort_direction)
    query = {
      query: {
        bool: {
          must: [  ]
        }
      },
      sort: [
        { "#{sort_column}" => "#{sort_direction}"}
      ]
    }
    if !params["sSearch"].blank?
      query[:query][:bool][:must] <<  {
                                        match: { 
                                          _all: {
                                            query: "%#{params["sSearch"]}%"
                                          }
                                        }
                                      }
      query[:query][:bool][:should] <<  {
        match: { 
          "contacts" => "%#{params["sSearch"]}%"
        }
      }
      query[:query][:bool][:should] <<  {
        match: { 
          "agencies" => "%#{params["sSearch"]}%"
        }
      }
      query[:query][:bool][:should] <<  {
        match: { 
          "name" => "%#{params["sSearch"]}%"
        }
      }
    end
    if !params[:platform].blank?
      query[:query][:bool][:must] << {
                                        match_phrase: {
                                          "platform" => params[:platform]
                                        }
                                      }
    end
    if !params[:status].blank?
      query[:query][:bool][:must] << {
                                        match_phrase: {
                                          "status" => params[:status]
                                        }
                                      }
    end
    if !params[:agency].blank?
      query[:query][:bool][:must] << {
                                        match_phrase: {
                                          "agencies" => params[:agency]
                                        }
                                      }
    end
    self.search(query)
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

  def published!
    MobileApp.public_activity_off
    self.status = MobileApp.statuses[:published]
    ma.save(validate: false)
    MobileApp.public_activity_on
    self.create_activity :published
  end

  def archived!
    MobileApp.public_activity_off
    self.status = MobileApp.statuses[:archived]
    self.save(validate: false)
    MobileApp.public_activity_on
    self.create_activity :archived
  end

  def publish_requested!
    MobileApp.public_activity_off
    self.status = MobileApp.statuses[:publish_requested]
    self.save(validate: false)
    MobileApp.public_activity_on
    self.create_activity :publish_requested
  end

  def archive_requested!
    MobileApp.public_activity_off
    self.status = MobileApp.statuses[:archive_requested]
    self.save(validate: false)
    MobileApp.public_activity_on
    self.create_activity :archive_requested
  end

end
