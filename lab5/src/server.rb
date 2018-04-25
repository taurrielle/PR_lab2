require 'socket'
require 'pry'
require 'levenshtein'
require 'json'
require 'zlib'

class Server
  def initialize(socket_port, socket_address)
    @server_socket = TCPServer.open(socket_address, socket_port)
    @commands = {
      "/hello"        => method(:hello_command),
      "/help"         => method(:help_command),
      "/time_now"     => method(:time_now),
      "/generate_num" => method(:generate_num),
      "/coin_flip"    => method(:coin_flip),
      "/get_file"     => method(:get_file)
    }

    @commands_info = {
      "/hello <param>"                  => "Prints 'Hello <param>'",
      "/time_now"                       => "Prints the current time",
      "/generate_num <param1> <param2>" => "Prints a randomly generated number between the two <param> values",
      "/coin_flip"                      => "Prints the result of flipping a coin",
      "/help"                           => "Prints all the supported commands",
      "/get_file"                       => "Saves a file from server in the current directory"
    }

    puts "Started server.........\n"
    run
  end

  def run
    loop {
      client_connection = @server_socket.accept
      puts client_connection
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
          else
            conn.puts(check_command(command))
          end
        end
      end
    }.join
  end

  private

  def check_command(command)
    cmd_distances = {}
    @commands.each_key do |cmd|
      cmd_distances[cmd] = Levenshtein.distance(command, cmd)
    end

    min_distance = cmd_distances.values.sort.first

    if min_distance <= 2
      "Undefined command '#{command}'.\nDid you mean? #{cmd_distances.key(min_distance)}"
    else
      "Undefined command '#{command}'"
    end
  end

  def help_command
    result = "\n"
    @commands_info.each do |key, value|
      result << "#{key.ljust(40)}##{value}\n"
    end
    result
  end

  def hello_command(param="")
    param = param.join(" ") if param.kind_of?(Array)
    "Hello #{param}"
  end

  def time_now
    "#{Time.now}"
  end

  def generate_num(params)
    return "Wrong number of arguments" if params.length != 2
    return "Incorrect parameter type" unless is_number?(params.first) and is_number?(params.last)

    min = params.first.to_i < params.last.to_i ? params.first.to_i : params.last.to_i
    max = params.first.to_i < params.last.to_i ? params.last.to_i : params.first.to_i

    "\nYour number: #{Random.new.rand(min..max)}\n"
  end

  def coin_flip
    rand(2) == 0 ? "Heads!" : "Tails!"
  end

  def is_number?(string)
    true if Float(string) rescue false
  end

  def get_file
    file = File.open('test.txt', 'rb')
    file_name = File.basename(file)
    "#{file_name} #{file.read}"
  end
end

Server.new( 2000, "localhost" )