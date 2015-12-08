class User < ActiveRecord::Base
  validates :email_address, email_format: true, allow_blank: true
  validates :name, presence: true

  def user_agent=(user_agent)
    browser = Browser.new(ua: user_agent)
    self.user_agent_meta = browser.meta.join(",")
    self.user_agent_hash = Digest::SHA256.hexdigest(user_agent)
  end

  def ip_address=(ip_address)
    self.ip_address_hash = Digest::SHA256.hexdigest(ip_address)
  end

  def request_headers=(request_headers)
    self.ip_address = request_headers['X-Forwarded-For'] || request_headers['REMOTE_ADDR']
    self.user_agent = request_headers['HTTP_USER_AGENT']
  end
end
