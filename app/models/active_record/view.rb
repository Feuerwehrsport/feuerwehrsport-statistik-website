class ActiveRecord::View < ActiveRecord::Base
  self.abstract_class = true

  protected

  def readonly?
    true
  end
end