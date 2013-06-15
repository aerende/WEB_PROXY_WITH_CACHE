
1.  The LRUCache consists of two data structures:

A. A doubly linked list of nodes.  The nodes are arrays:
node = [prev, key, val, next, num_bytes]
@head -> prev -> prev -> @tail
@head <- next <- next <- @tail

B. A hash, @hash, that returns a node when presented with a key
Once the node is known you can move the node to the head and also get the node's value

2.  If the new item to be added to the cache overfills the cache, then the tail
node is removed until there is space in the cache for the new entry.  If the new
entry is too big for the cache then the new entry isn't added to the cache.


3.  Start web_proxy.rb as
    ./web_proxy.rb

4.  Click on Safari Preferences->Advanced->Proxies-Change Settings

5.  Select "Web Proxy" and enter
    Web Proxy Server = localhost
    Port = 8008
    Click OK

6.  On the Network Page for Ethernet 1 click Apply

