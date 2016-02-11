module CompReg
  class PersonDecorator < ApplicationDecorator
    decorates_association :team
    decorates_association :competition
  end
end