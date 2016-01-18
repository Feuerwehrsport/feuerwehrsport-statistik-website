class ChangeLogDecorator < ApplicationDecorator
  def diff_hash
    object.content[:before_hash].deep_diff(object.content[:after_hash])
  end
end
