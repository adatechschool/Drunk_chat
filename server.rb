require 'socket'
require 'colorize'

class Server
    def initialize(socket_address, socket_port)
        @server_socket = TCPServer.open(socket_port, socket_address)

        @connections_details = Hash.new
        @connected_clients = Hash.new

        @connections_details[:server] = @server_socket
        @connections_details[:clients] = @connected_clients

        puts 'Started server.........'
        run

    end

    def run
        loop{
            client_connection = @server_socket.accept
            Thread.start(client_connection) do |conn| # open thread for each accepted connection
                conn_name = conn.gets.chomp
                if(@connections_details[:clients][conn_name] != nil) # avoid connection if user exits
                    conn.puts "This username already exist"
                    conn.puts "quit"
                    conn.kill self
                end

                puts "Connection established #{conn_name} => #{conn}"
                @connections_details[:clients][conn_name] = conn
                conn.puts "Connection established successfully #{conn_name} => #{conn}, you may continue with chatting....."

                establish_chatting(conn_name, conn) # allow chatting
            end
        }.join
    end

    def establish_chatting(username, connection)
        loop do
            message = connection.gets
            if message == nil
                @connections_details[:clients][client].close
                @connections_details[:clients].delete(client)
            end
            message.chomp!
            if message == "j'ai plus soif"
                puts "#{username} a vomi et est rentré chez elle" 
                puts "au reboire"
            end
            if message == "kill server" and @connected_clients.count == 1
                exit
            end
            #puts @connections_details[:clients]
            (@connections_details[:clients]).keys.each do |client|
                @connections_details[:clients][client].puts "#{username} : #{message}"

            end
        end
    end
end

Server.new( 8080, "localhost" )
