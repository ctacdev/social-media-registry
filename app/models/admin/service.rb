class Admin::Service < ApplicationRecord
  serialize :account_matchers_eval, Hash

  scope :sorted, -> { order(:shortname) }
  scope :every, -> { sorted }
  scope :unarchived, -> { where(archived: false).sorted }

  def self.find_by_shortname(shortname)
    find_by(shortname: shortname.to_s)
  end

  def self.search_by_name(query)
    where('shortname LIKE ?', "%#{query.downcase}%").to_a
  end

  def self.find_by_url(url)
    begin
      uri = URI.parse(url.downcase)
    rescue
      return nil
    end

    all.each do |service|
      if service.handles?(uri)
        return ServiceBinding.new(service, uri)
      end
    end

    return nil
  end

  def handles?(uri)
    handles_regex_eval.to_regexp =~ uri.host
  end
end

# == Schema Information
#
# Table name: admin_services
#
#  id                         :integer          not null, primary key
#  handles_regex_eval         :string(255)
#  shortname                  :string(255)
#  longname                   :string(255)
#  display_name_eval          :string(255)
#  account_matchers_eval      :text(65535)
#  service_url_example        :string(255)
#  service_url_canonical_eval :string(255)
#  archived                   :boolean          default(FALSE)
#  created_at                 :datetime         not null
#  updated_at                 :datetime         not null
#
