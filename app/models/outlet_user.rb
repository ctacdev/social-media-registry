# == Schema Information
#
# Table name: outlet_users
#
#  id        :integer          not null, primary key
#  outlet_id :integer
#  user_id   :integer
#

class OutletUser < ApplicationRecord
  belongs_to :user
  belongs_to :outlet
end
