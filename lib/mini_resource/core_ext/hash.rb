#
# Monkey patch (or should that be put)
#
class Hash
  def method_missing(method_name, *args, &blk)
    self[method_name] if self.has_key?(method_name)
  end
end

