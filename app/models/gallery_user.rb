# == Schema Information
#
# Table name: gallery_users
#
#  id         :integer          not null, primary key
#  gallery_id :integer
#  user_id    :integer
#

class GalleryUser < ApplicationRecord
  belongs_to :gallery
  belongs_to :user
end
