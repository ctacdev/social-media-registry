# == Schema Information
#
# Table name: gallery_items
#
#  id         :integer          not null, primary key
#  gallery_id :integer
#  item_id    :integer
#  item_type  :string(255)
#  item_order :integer          default(0)
#

class GalleryItem < ApplicationRecord
  belongs_to :gallery
  belongs_to :item, polymorphic: true

  def published_item
    self.item_type.constantize.find_by(draft_id: self.item_id)
  end
end
