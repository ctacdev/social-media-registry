# == Schema Information
#
# Table name: agencies
#
#  id               :integer          not null, primary key
#  name             :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  shortname        :string(255)
#  info_url         :string(255)
#  mongo_id         :string(255)
#  parent_mongo_id  :string(255)
#  parent_id        :integer
#  outlet_count     :integer          default("0")
#  mobile_app_count :integer          default("0")
#  gallery_count    :integer          default("0")
#

require 'rails_helper'

RSpec.describe Agency, type: :model do
  it "should pass validations" do
    agency = FactoryGirl.create(:agency)
    expect(agency.valid?).to eq(true)
  end

end