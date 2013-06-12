
The LRUCache consists of two data structures:

1. A doubly linked list of nodes.  The nodes are arrays:
node = [prev, key, val, next, num_bytes]
@head -> prev -> prev -> @tail
@head <- next <- next <- @tail

2. A hash, @data, that returns a node when presented with a key
Once the node is known you can move the node to the head and also get the node's value


3.  Start web_proxy.rb as
    ./web_proxy.rb

4.  Click on Safari Preferences->Advanced->Proxies-Change Settings

5.  Select "Web Proxy" and enter
    Web Proxy Server = localhost
    Port = 8008
    Click OK

6.  On the Network Page for Ethernet 1 click Apply

