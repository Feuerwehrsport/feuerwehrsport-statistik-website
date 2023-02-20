# frozen_string_literal: true
# see https://gist.github.com/henrik/146844

class Hash
  def deep_diff(other)
    me = self
    (me.keys | other.keys).each_with_object({}) do |k, diff|
      next unless me[k] != other[k]

      diff[k] = if me[k].respond_to?(:deep_diff) && other[k].respond_to?(:deep_diff)
                  me[k].deep_diff(other[k])
                else
                  [me[k], other[k]]
                end
    end
  end
end
