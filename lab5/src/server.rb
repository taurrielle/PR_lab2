require 'socket'
require 'pry'
require 'levenshtein'
require 'json'

class Server
  def initialize(socket_port, socket_address)
    @server_socket = Socket.new(Socket::AF_INET, Socket::SOCK_STREAM, 0)
    sockaddr = Socket.sockaddr_in(socket_port, socket_address)
    @server_socket.bind(sockaddr)
    @server_socket.listen(5)

    # @server_socket = TCPServer.open(socket_address, socket_port)
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

    begin
      run
    rescue Interrupt
      puts "\nExiting..."
      @server_socket.close
    end
  end

  def run
    loop {
      client_connection, client_addrinfo = @server_socket.accept
      puts client_connection
      Thread.start(client_connection) do |conn| # open thread for each accepted connection
        loop do
          request = conn.gets.chomp
          next if request.empty?

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
      "Undefined command '#{command}'.\nDid you mean? #{cmd_distances.key(min_distance)}\n\n"
    else
      "Undefined command '#{command}'\n\n"
    end
  end

  def help_command
    result = "\n"
    @commands_info.each do |key, value|
      result << "#{key.ljust(40)}##{value}\n"
    end
    result + "\n"
  end

  def hello_command(param="")
    param = param.join(" ") if param.kind_of?(Array)
    "Hello #{param}\n\n"
  end

  def time_now
    "#{Time.now}\n\n"
  end

  def generate_num(params)
    return "Wrong number of arguments" if params.length != 2
    return "Incorrect parameter type" unless is_number?(params.first) and is_number?(params.last)

    min = params.first.to_i < params.last.to_i ? params.first.to_i : params.last.to_i
    max = params.first.to_i < params.last.to_i ? params.last.to_i : params.first.to_i

    "Your number: #{Random.new.rand(min..max)}\n\n"
  end

  def coin_flip
    rand(2) == 0 ? "Heads!\n\n" : "Tails!\n\n"
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

Server.new( 2220, "localhost" )