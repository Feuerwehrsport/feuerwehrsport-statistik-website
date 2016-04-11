class ImportRequest < ActiveRecord::Base
  belongs_to :place
  belongs_to :event
  belongs_to :admin_user
end
