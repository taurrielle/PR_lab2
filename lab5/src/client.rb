require 'socket'
require 'json'
require 'pry'
require 'zlib'

class Client
  def initialize(socket)
    @socket = socket
    @request_object = send_request
    @response_object = listen_response
    @file_flag = false

    @request_object.join # will send the request to server
    @response_object.join # will receive response from server
  end

  def send_request
    Thread.new do
      loop do
        message = $stdin.gets.chomp
        @file_flag = true if message == "/get_file"

        @socket.puts message
      end
    end
  end

  def listen_response
    Thread.new do
      loop do
        response = @socket.readline.chomp

        if @file_flag
          split_response = response.split(' ', 2)
          file_name = split_response.first
          content = split_response.last

          file_name = file_name.split('.').first + "_rec." + file_name.split('.').last

          file = File.open("#{file_name}", "wb")
          file.print content
          file.close

          puts "File saved"

          @file_flag = false
        else
          puts "#{response}"
        end

        if response.eql?'quit'
          @socket.close
        end
      end
    end
  end
end

# sockaddr = @server_socket.connect Socket.pack_sockaddr_in(socket_port, socket_address)

# socket = Socket.new Socket::INET, Socket::SOCK_STREAM
# socket.connect Socket.pack_sockaddr_in(2000, "localhost")

# socket = TCPSocket.open( "localhost", 2000 )

socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
sockaddr = Socket.sockaddr_in(2220, 'localhost')
socket.connect(sockaddr)
Client.new( socket )