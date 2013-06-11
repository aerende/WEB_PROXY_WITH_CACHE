

class LruCache::Cache

  # The LRUCache consists of two data structures:
  # 1. A doubly linked list of nodes.  The nodes are arrays:
  # node = [prev, key, val, next, num_bytes]
  # @head -> prev -> prev -> @tail
  # @head <- next <- next <- @tail
  #
  # 2. A hash, @data, that returns a node when presented with a key
  # Once the node is known you can move it to the head and also get the value

  MAX_CACHE_SIZE = 5242880   # 5 MBytes

  def initialize(max_size)  # max_size is number of entries not cache size in bytes
    @max_size = max_size
    @data = {}
    @head = nil
    @tail = nil
    @cache_size = 0
  end

  def max_cache_size
    MAX_CACHE_SIZE
  end

  def max_size=(size)
    raise ArgumentError.new(:max_size) if @max_size < 1
    @max_size = size
    while pop_tail
      # no op
    end
  end

# def getset(key)
#   node = @data[key]
#   if node
#     move_to_head(node)
#     node[2]
#   else
#    self[key] = yield
#   end
# end

# def fetch(key)
#   node = @data[key]
#   if node
#     move_to_head(node)
#     node[2]
#   else
#    yield if block_given?
#   end
# end

  def [](key)
    node = @data[key]
    if node
      move_to_head(node)
      node[2]
    end
  end

  # not sure if this is needed since add_to_head needs num_bytes

  def []=(key,val)
    node = @data[key]
    if node
      move_to_head(node)
      node[2] = val
    else
      @data[key] = add_to_head(key,val)
      pop_tail
    end
    val
  end

  def add_to_cache(key,val, num_bytes)
    node = @data[key]
puts "add_to_cache 0 - @cache_size = #{@cache_size}, num_bytes = #{num_bytes}"
    if(@cache_size + num_bytes < MAX_CACHE_SIZE)
      @cache_size = @cache_size + num_bytes

      if node
        move_to_head(node)
        node[2] = val
      else
        @data[key] = add_to_head(key, val, num_bytes)
        pop_tail
      end
      return 1

    else
puts "add_to_cache 2a"
      # remove tail
      @cache_size = @cache_size - @tail[4]
      @data.delete(@tail[1])
      if (!@tail[3].nil?)
        @tail = @tail[3]
        @tail[0] = nil
      end
      return 0

    end  #  if(@cache_size + num_bytes < MAX_CACHE_SIZE)
#     val
  end

  def each
    if n = @head
      while n
        yield [n[1], n[2]]
        n = n[0]
      end
    end
  end


  # used further up the chain, non thread safe each
  alias_method :each_unsafe, :each

  def to_a
    a = []
    self.each_unsafe do |k,v|
      a << [k,v]
    end
    a
  end

  def delete(k)
    if node = @data.delete(k)
      prev = node[0]
      nex = node[3]

      prev[3] = nex if prev
      nex[0] = prev if nex
    end
  end

  def clear
    @data.clear
    @head = @tail = nil
  end

  def count
    @data.count
  end

  # for cache validation only, ensures all is sound
  def valid?
    expected = {}

    count = 0
    self.each_unsafe do |k,v|
      return false if @data[k][2] != v
      count += 1
    end
    count == @data.count
  end






  def add_to_head(key,val, num_bytes)
    if @head.nil?
      @tail = @head = [nil, key, val, nil, num_bytes]
    else
      node = [@head, key, val, nil, num_bytes]
      @head = @head[3] = node
    end
  end



#############################################

  protected


  def pop_tail
    if @data.length > @max_size
      removed_size = @tail[4]
      @data.delete(@tail[1])
      @tail = @tail[3]
      @tail[0] = nil
      true
    end
    removed_size
  end


  def move_to_head(node)
    return unless @head && node[1] != @head[1]

    # start of delete

    prev = node[0]
    nex = node[3]

    if prev
      prev[3] = nex
    else
      @tail = nex
    end

    if nex
      nex[0] = prev
    end

    # end of delete

    @head[3] = node
    node[0] = @head
    @head = node
  end


end
