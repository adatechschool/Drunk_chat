require 'socket'
require 'colorize'

class Server
    def initialize(socket_address, socket_port)
        @server_socket = TCPServer.open(socket_port, socket_address)

        @connections_details = Hash.new
        @connected_clients = Hash.new

        @connections_details[:server] = @server_socket
        @connections_details[:clients] = @connected_clients

        puts 'Bienvenue à la taverne, prenez place !'
        run

    end

    def run
        loop{
            client_connection = @server_socket.accept
            Thread.start(client_connection) do |conn| # open thread for each accepted connection
                conn_name = conn.gets.chomp
                if(@connections_details[:clients][conn_name] != nil) # avoid connection if user exits
                    conn.puts "Un des participants a déja choisi ce blaze.. oups"
                    conn.puts "quit"
                    conn.kill self
                end

                puts "En avant ! #{conn_name} => #{conn}"
                @connections_details[:clients][conn_name] = conn
                conn.puts "Tout est en place #{conn_name} => #{conn}, vous pouvez commencer à raconter votre vie, n'hésitez pas à boire un verre !"

                establish_chatting(conn_name, conn) # allow chatting
            end
        }.join
    end

    def establish_chatting(username, connection)
        loop do
            (@connections_details[:clients]).keys.each do |client|
                message = connection.gets
                if message == nil
                    @connections_details[:clients][client].close
                    @connections_details[:clients].delete(client)
                end
                message.chomp!
                mots_dangereux = ["boire", "ça", "ca", "va","tyrannosaure", "soirée", "quoi"]
                if message == "j'ai plus soif"
                    puts "#{username} a vomi et est rentré chez elle" 
                    puts "au reboire"
                end
                if message == "kill server" and @connected_clients.count == 1
                    exit
                end
                tab = message.split(' ')
                for words in tab
                    if mots_dangereux.include? words
                        @connection_details[:clients][client].puts "un ptit pour la route"
                        break
                    end
                end

                @connections_details[:clients][client].puts "#{username} : #{message}"
            end
        end
    end
end

Server.new( 8080, "localhost" )
