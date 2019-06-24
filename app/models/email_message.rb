# == Schema Information
#
# Table name: email_messages
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  to         :text(65535)
#  subject    :string(255)
#  body       :text(65535)
#  created_at :datetime
#  updated_at :datetime
#

class EmailMessage < ApplicationRecord
	belongs_to :user

	validates :to, :presence => true
	validates :subject, :presence => true
	validates :body, :presence => true

  paginates_per 25
end
