
The LRUCache consists of two data structures:

1. A doubly linked list of nodes.  The nodes are arrays:
node = [prev, key, val, next, num_bytes]
@head -> prev -> prev -> @tail
@head <- next <- next <- @tail

2. A hash, @data, that returns a node when presented with a key
Once the node is known you can move the node to the head and also get the node's value

3.  If the new item to be added to the cache overfills the cache, then the tail
node is removed until there is space in the cache for the new entry.  If the new
entry is too big for the cache then the new entry isn't added to the cache.


4.  Start web_proxy.rb as
    ./web_proxy.rb

5.  Click on Safari Preferences->Advanced->Proxies-Change Settings

6.  Select "Web Proxy" and enter
    Web Proxy Server = localhost
    Port = 8008
    Click OK

7.  On the Network Page for Ethernet 1 click Apply

