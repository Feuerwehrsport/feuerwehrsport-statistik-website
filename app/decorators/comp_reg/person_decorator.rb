module CompReg
  class PersonDecorator < ApplicationDecorator
    decorates_association :team
    decorates_association :competition
    decorates_association :admin_user
  end
end