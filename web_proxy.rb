#!/usr/bin/env ruby
# encoding: UTF-8
#
#
#  localhost:8765/
#

 
require 'socket'
require 'uri'
require 'lru_cache'
 
 
class WebProxy  
  def web_proxy port
    begin

      # Initialize cache
      @cache = LruCache::ThreadSafeCache.new(1000)   # of entries not number of bytes

      # Start server to accept connections 
      @socket = TCPServer.new('localhost',  port)
      @thread_number = 0
      
      # Handle every request in another thread
      loop do
      @thread_number = @thread_number + 1
        puts "---------- New Thread ----------- thread_number = " + @thread_number.to_s
        socket_accept = @socket.accept
        Thread.new socket_accept, &method(:receive_socket_data)
      end
      
    # Interrupts
    rescue Interrupt
      puts 'Received Interrupt..'
    # Release the socket whem errors occur
    ensure
      if @socket
        @socket.close
        puts 'Socket closed.'
      end
      puts 'Finished.'
    end
  end

  ################################################
  
  def receive_socket_data io_client
    request_line = io_client.readline    # io_client is io with the browser, io_server is io with the Internet 

    verb    = request_line[/^\w+/]
    url     = request_line[/^\w+\s+(\S+)/, 1]
    version = request_line[/HTTP\/(1\.\d)\s*$/, 1]
    uri     = URI::parse url


    # Show url parts from request
    puts(("Request -  verb = %4s  version = %4s uri.host = %4s uri.port = %4s uri.query = %4s "% [verb, version, uri.host, uri.port, uri.query] ) + url)

    url_key = url


      io_server = TCPSocket.new(uri.host, (uri.port.nil? ? 80 : uri.port))
      io_server.write("#{verb} #{uri.path}?#{uri.query} HTTP/#{version}\r\n")


    @cache.each do |k, v|
      puts "Cache key   = #{k}" 
    end
    

    #########################################################################################################################################################################
    ####################################################### if not Found in cache  ############################################################################################
    #########################################################################################################################################################################

    if( @cache[url_key].nil?)
      puts "Not found in cache ###########################################################, url_key = " + url_key


      write_server = 1
      read_client_write_server(io_client, io_server, write_server)

      # web page returned from server
      website_data_size, website_data = read_server_write_client(io_client, io_server )

      

      # Save website_data to cache for key = url_key, value = website_data 
      # 1. Each attempt to add to the cache, if unsuccessful because of not enough space remaining, will remove the tail to make space
      # 2. If website_data_size is greater than max_cache_size, then don't try to save the website response

      added = 0
      while(added == 0)
        max_cache_size = @cache.max_cache_size
        puts "Add to Cache 1 - website_data_size = #{website_data_size}, max_cache_size = #{max_cache_size} "
        if(website_data_size  > max_cache_size)
          added = 1
        else 
          added = @cache.add_to_cache(url_key, website_data, website_data_size)
          puts "Add to Cache 2 - add received response to size of cache"
        end
      end


    #########################################################################################################################################################################
    ####################################################### else Found in cache  ############################################################################################
    #########################################################################################################################################################################


    else

      puts "Send from cache ########################################################### Thread.current.id = #{Thread.current.object_id},  url_key = " + url_key

      output_array = @cache[url_key]

      write_server = 0
      read_client_write_server(io_client, io_server, write_server)


      # cached web page sent from cache to client

      output_array.each do |out_line|
        io_client.write(out_line)
      end


      end # if not found in cache, else send from cache


    
    # Close the sockets
    io_client.close
    io_server.close
  end  #  receive_socket_data

  ###########################

   def read_client_write_server(io_client, io_server, write_server)
      content_len = 0

      loop do
        line = io_client.readline

        if line =~ /^Content-Length:\s+(\d+)\s*$/
          content_len = $1.to_i
          puts "Content-Length = " + content_len.to_s
        end

        # Strip proxy headers
        if line =~ /^proxy/i
          next
        elsif line.strip.empty?
          if(write_server == 1)
            io_server.write("Connection: close\r\n\r\n")

            if (content_len >= 0)
              io_server.write(io_client.read(content_len))
            end
          end

          break
        else
          if(write_server == 1)
            io_server.write(line)
          end
        end
      end  # end loop

   end

  ###########################

   def read_server_write_client(io_client, io_server)
      # web page returned from server

      website_data_size = 0
      website_data = []
      index = 0


      loop do
        buff = ""
        io_server.read(4048, buff)
        website_data[index] =  buff
        website_data_size = website_data_size + buff.length
        io_client.write(buff)
        index += 1
        break if buff.size < 4048
      end

      return website_data_size, website_data

   end # read_server_write_client

  ###########################
  
end  # WebProxy
 
 
# Command line arguments - Start the server

if ARGV.empty?
  port = 8765
elsif ARGV.size == 1
  port = ARGV[0].to_i
else
  puts 'Usage: web_proxy.rb [port]'
  exit 1
end
 
WebProxy.new.web_proxy port



