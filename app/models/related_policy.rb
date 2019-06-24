# == Schema Information
#
# Table name: related_policies
#
#  id           :integer          not null, primary key
#  service_wide :boolean
#  service      :string(255)
#  title        :string(255)
#  url          :string(255)
#  description  :string(255)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#

class RelatedPolicy < ApplicationRecord


  has_many :outlet_related_policies
  has_many :outlets, through: :outlet_related_policies
end
