module Caching::Keys
  extend ActiveSupport::Concern
  def caching_key(uniq)
    "#{self.class.table_name}--#{id}--#{uniq}"
  end
end
