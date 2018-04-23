require 'socket'
require 'pry'

class Server
  def initialize(socket_address, socket_port)
    @server_socket = TCPServer.open(socket_port, socket_address)
    @commands = {
      "/hello" => method(:hello_command),
      "/help"  => method(:help_command)
    }

    puts "Started server.........\n"
    run
  end

  def run
    loop {
      client_connection = @server_socket.accept
      Thread.start(client_connection) do |conn| # open thread for each accepted connection
        loop do
          request = conn.gets.chomp

          command = request.split(' ')[0]
          params = request.split(' ')[1..-1]

          if @commands.key?(command)
            if params == []
              conn.puts(@commands[command].call)
            else
              conn.puts(@commands[command].call(params))
            end
          end
        end
      end
    }.join
  end

  private

  def help_command
    commands_description = {
      "/hello <param>" => "Prints 'Hello <param>'",
      "/help"          => "Prints all the supported commands"
    }

    commands_description.each do |key, value|
      key + "\t#" + value
    end
  end

  def hello_command(param)
    param = param.join(" ") if param.kind_of?(Array)
    "Hello #{param}"
  end
end

Server.new( 2000, "localhost" )