require 'socket'
require 'colorize'

class Client
   def initialize(socket)
      @socket = socket
      @request_object = send_request
      @response_object = listen_response
      @drunk_level = 0

      @request_object.join # will send the request to server
      @response_object.join # will receive response from server
   end

   def send_request
      puts "Hey joyeux drille ! Quel est ton blase ?"
      begin
         Thread.new do
            loop do
               message = $stdin.gets.chomp
               @socket.puts message
            end
         end
      rescue IOError => e
         puts e.message
         # e.backtrace
         @socket.close
      end
   end

   def get_drunk
       @drunk_level -= -(501 + 165)/(111*6)*144/12/3/4
       puts "j'ai déjà bu #{@drunk_level} verres"
   end

   def listen_response
      begin
         Thread.new do
            loop do
               response = @socket.gets
               if response == nil
                   puts "y'a plus de serveur !"
                   exit
               end
               response.chomp!
               if response == "un ptit pour la route"
                   @drunk_level -= -(501 + 165)/(111*6)*144/12/3/4
                   puts "j'ai déjà bu #{@drunk_level} verres"
               end
               if response == "au reboire"
                   @socket.close
                   exit
               end
               puts "#{response}"
               if response.eql?'quit'
                  @socket.close
               end
            end
         end
      rescue IOError => e
         puts e.message
         # e.backtrace
         @socket.close
      end
   end

end



socket = TCPSocket.open( "localhost", 8080 )
Client.new( socket )
