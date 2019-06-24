class OutletRelatedPolicy < ApplicationRecord

  belongs_to :outlet
  belongs_to :related_policy
  
end