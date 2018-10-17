# see https://gist.github.com/henrik/146844

class Hash
  def deep_diff(b)
    a = self
    (a.keys | b.keys).each_with_object({}) do |k, diff|
      next unless a[k] != b[k]

      diff[k] = if a[k].respond_to?(:deep_diff) && b[k].respond_to?(:deep_diff)
                  a[k].deep_diff(b[k])
                else
                  [a[k], b[k]]
                end
    end
  end
end
