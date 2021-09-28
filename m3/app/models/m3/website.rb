# frozen_string_literal: true

require_dependency 'm3'

class M3::Website < ApplicationRecord
  has_many :logins, class_name: 'M3::Login::Base', inverse_of: :website
  has_one :delivery_setting, class_name: 'M3::DeliverySetting', inverse_of: :website
  validates :name, :domain, :key, :title, :delivery_setting, presence: true
  validates :name, :domain, :key, uniqueness: true
  validates :port, numericality: { greater_than: 0, less_than: 65_536, only_integer: true }
  validates :protocol, inclusion: { in: %i[http https] }
  validates_associated :delivery_setting

  def key
    super&.to_sym
  end

  def layout
    'm3_bootstrap_v1'
  end

  def protocol
    super&.to_sym
  end

  def delivery_setting
    super || build_delivery_setting
  end

  def path_to_url(path)
    uri_class = protocol == :https ? URI::HTTPS : URI::HTTP
    uri_class.build(host: domain, port: port, path: path).to_s
  end

  def url_options_hash
    {
      host: domain,
      port: port,
      protocol: protocol,
    }
  end
end
