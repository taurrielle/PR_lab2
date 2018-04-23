require 'socket'
require 'pry'

class Server
  def initialize(socket_port, socket_address)
    @server_socket = TCPServer.open(socket_address, socket_port)
    @commands = {
      "/hello"        => method(:hello_command),
      "/help"         => method(:help_command),
      "/time_now"     => method(:time_now),
      "/generate_num" => method(:generate_num),
      "/coin_flip"    => method(:coin_flip)
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
      "/hello <param>"                  => "Prints 'Hello <param>'",
      "/time_now"                       => "Prints the current time",
      "/generate_num <param1> <param2>" => "Prints a randomly generated number between the two <param> values",
      "/flip_cpin"                      => "Prints the result of flipping a coin",
      "/help"                           => "Prints all the supported commands"
    }

    result = "\n"
    commands_description.each do |key, value|
      result << "#{key.ljust(30)}##{value}\n"
    end
    result
  end

  def hello_command(param)
    param = param.join(" ") if param.kind_of?(Array)
    "Hello #{param}"
  end

  def time_now
    "#{Time.now}"
  end

  def generate_num(params)
    return "Wrong number of arguments" if params.length > 2
    return "Incorrect parameter type" unless is_number?(params.first) and is_number?(params.last)

    min = params.first.to_i < params.last.to_i ? params.first.to_i : params.last.to_i
    max = params.first.to_i < params.last.to_i ? params.last.to_i : params.first.to_i

    "\nYour number: #{Random.new.rand(min..max)}\n"
  end

  def coin_flip
    result = Random.rand(2)
    if result == 0
      "Heads!"
    else
      "Tails!"
    end
  end

  def is_number?(string)
    true if Float(string) rescue false
  end
end

Server.new( 2000, "localhost" )