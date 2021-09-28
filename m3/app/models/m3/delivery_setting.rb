# frozen_string_literal: true

class M3::DeliverySetting < ApplicationRecord
  belongs_to :website

  validates :website, presence: true
  validates :delivery_method, inclusion: { in: %i[test file smtp sendmail exim] }
  validates :port, numericality: { greater_than: 0, less_than: 65_536, only_integer: true, allow_blank: true }
  validates :authentication, inclusion: { in: %i[plain login cram_md5], allow_blank: true }
  validates :openssl_verify_mode, inclusion: { in: %w[none peer client_once fail_if_no_peer_cert], allow_blank: true }

  def delivery_method
    super.try(:to_sym)
  end

  def authentication
    super.try(:to_sym)
  end

  def to_settings_hash
    hash = {}
    case delivery_method
    when :smtp
      %i[address port domain user_name password authentication enable_starttls_auto openssl_verify_mode tls]
    when :sendmail, :exim
      %i[location arguments]
    when :file
      [:location]
    else
      []
    end.each do |attribute|
      hash[attribute] = send(attribute) unless send(attribute).nil?
    end
    hash
  end
end
