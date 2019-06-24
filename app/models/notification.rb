# == Schema Information
#
# Table name: notifications
#
#  id                :integer          not null, primary key
#  user_id           :integer
#  item_id           :integer
#  item_type         :string(255)
#  message           :string(255)
#  message_type      :string(255)
#  notification_type :string(255)
#  has_read          :boolean          default(FALSE)
#  created_at        :datetime
#  updated_at        :datetime
#

class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :item, polymorphic: true

  after_create :send_notification

  def send_notification
    if ( notification_type == "agency" && user.agency_notifications_emails ) ||
        ( notification_type == "contact" && user.contact_notifications_emails ) ||
        ( notification_type == "admin" )
      NotificationMailer.email(self).deliver_later
    end
  end
  
end
