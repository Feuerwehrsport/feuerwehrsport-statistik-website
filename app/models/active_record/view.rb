module ActiveRecord
  class View < Base
    self.abstract_class = true

    protected

    def readonly?
      true
    end
  end
end