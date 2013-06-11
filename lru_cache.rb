


module LruCache
  def self.is_19?
    major,minor = RUBY_VERSION.split(".").map{|a| a.to_i}
    major > 1 || (major == 1 && minor > 8)
  end
end

require "lru_cache/version"
if LruCache.is_19?
# require "lru_cache/cache19"
  require "lru_cache/cache"
else
  require "lru_cache/cache"
end
require "lru_cache/thread_safe_cache"
