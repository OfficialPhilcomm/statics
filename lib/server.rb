require 'thin'
require 'listen'

module Statics
  class Server
    def initialize
      puts "Starting server..."

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
        file_names = modified
          .map do |file|
            file.gsub "#{Dir.pwd}/src/", ""
          end
          .join(", ")

        puts "#{file_names} changed, rebuilding..."
        Builder.new
        puts "Rebuilding successful"
      end
      listener.start
    end
  end
end
