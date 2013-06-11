require 'thread'
class LruCache::ThreadSafeCache < LruCache::Cache
  def initialize(size)
    @lock = Mutex.new
    super(size)
  end

  def self.synchronize_methods(*methods)
    methods.each do |method|
      define_method method do |*args, &blk|
        @lock.synchronize do
          super(*args, &blk)
        end   
      end     
    end       
  end         

  synchronize_methods :[], :[]=, :each, :to_a, :delete, :count, :valid?, :max_size, :add_to_cache, :addtohead_with_num_bytes, :remove_tail, :get_cache_size

end
