class ActiveRecord::View < ApplicationRecord
  self.abstract_class = true

  protected

  def readonly?
    true
  end
end
