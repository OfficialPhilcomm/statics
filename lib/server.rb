require 'thin'
require 'listen'

module Statics
  class Server
    def initialize
      puts "This is server"

      app = Rack::Builder.new do
        map "/" do
          run Rack::Directory.new("build")
        end
      end

      thin_server = Thin::Server.new '127.0.0.1', 3000
      thin_server.app = app

      Thread.new { listen_to_file_changes }
      thin_server.start
    end

    private

    def listen_to_file_changes
      listener = Listen.to('src') do |modified, added, removed|
        puts(modified: modified, added: added, removed: removed)
      end
      listener.start
    end
  end
end
