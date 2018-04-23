require 'socket'

# socket = TCPSocket.new 'localhost', 2000

class Client
  def initialize(socket)
    @socket = socket
    @request_object = send_request
    @response_object = listen_response

    @request_object.join # will send the request to server
    @response_object.join # will receive response from server
  end

  def send_request
    Thread.new do
      loop do
        message = $stdin.gets.chomp
        @socket.puts message
      end
    end
  end

  def listen_response
    Thread.new do
      loop do
        response = @socket.gets.chomp
        puts "#{response}"
        if response.eql?'quit'
          @socket.close
        end
      end
    end
  end
end


socket = TCPSocket.open( "localhost", 2000 )
Client.new( socket )