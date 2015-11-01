class Year < ActiveRecord::Base

  protected

  def readonly?
    true
  end
end
