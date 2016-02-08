module CompReg
  class PersonDecorator < ApplicationDecorator
    decorates_association :team
  end
end