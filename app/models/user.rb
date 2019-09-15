# == Schema Information
#
# Table name: users
#
#  id                           :integer          not null, primary key
#  email                        :string(255)      default(""), not null
#  remember_created_at          :datetime
#  sign_in_count                :integer          default(0)
#  current_sign_in_at           :datetime
#  last_sign_in_at              :datetime
#  current_sign_in_ip           :string(255)
#  last_sign_in_ip              :string(255)
#  created_at                   :datetime
#  updated_at                   :datetime
#  user                         :string(255)      not null
#  agency_id                    :integer
#  phone                        :string(255)
#  first_name                   :string(255)
#  last_name                    :string(255)
#  groups                       :text(65535)
#  role                         :integer          default(0)
#  agency_notifications         :boolean          default(FALSE)
#  agency_notifications_emails  :boolean          default(FALSE)
#  contact_notifications        :boolean          default(TRUE)
#  contact_notifications_emails :boolean          default(TRUE)
#  email_notification_type      :integer          default(0)
#

class User < ActiveRecord::Base

  belongs_to :agency
  
  devise :omniauthable, omniauth_providers: %i[openid_connect]

  enum role: { user: 0, super_user: 1, admin: 2, banned: 3}
  enum email_notification_type: { full_html_email: 0, plain_text_email: 1 }

  has_many :email_messages

  has_many :mobile_app_users
  has_many :mobile_apps, through: :mobile_app_users
  
  has_many :gallery_users
  has_many :gallerys, through: :gallery_users

  has_many :outlet_users
  has_many :outlets, :through => :outlet_users

  has_many :notifications
  serialize :agency_notifications_settings, :contact_notifications_settings

  paginates_per 200

  # def cas_extra_attributes=(extra_attributes)
  #   extra_attributes.each do |name, value|
  #     case name
  #       when "Email-Address"
  #         self.email = value
  #       when "Org-Agency-Name"
  #         new_agency = Agency.where("name LIKE ?","%#{value}%").first
  #         if new_agency == nil
  #           self.agency = Agency.create!(name: value)
  #         else
  #           self.agency = new_agency
  #         end
  #       when "Phone"
  #         self.phone = value
  #       when "First-Name"
  #         self.first_name = value
  #       when "Last-Name"
  #         self.last_name = value
  #       when "GroupList"
  #         self.groups = value 

  #         if self.groups.include? ENV['REGISTRY_ADMIN_GROUP']
  #           self.role = 2
  #         elsif self.groups.include? ENV['REGISTRY_USER_GROUP']
  #           self.role = 1
  #         else
  #           self.role = 0
  #         end
  #       when "samlAuthenticationStatementAuthMethod"
  #         self.user = value
  #     end
  #   end
  # end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name   # assuming the user model has a name
      user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails, 
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def cross_agency?
    admin? || super_user?
  end

end
