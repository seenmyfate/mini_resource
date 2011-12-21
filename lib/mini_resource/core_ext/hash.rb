#
# Monkey patch (or should that be put)
#
class Hash
  def method_missing(method_name, *args, &blk)
    self[method_name] if self.has_key?(method_name)
  end
  def deep_symbolize_keys
    inject({}) do |result, (key, value)|
      value = value.deep_symbolize_keys if value.is_a?(Hash)
    result[(key.to_sym rescue key) || key] = value
    result
    end
  end
end

