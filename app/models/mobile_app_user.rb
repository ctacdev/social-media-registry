# == Schema Information
#
# Table name: mobile_app_users
#
#  id            :integer          not null, primary key
#  mobile_app_id :integer
#  user_id       :integer
#

class MobileAppUser < ApplicationRecord
  belongs_to :user
  belongs_to :mobile_app
end
