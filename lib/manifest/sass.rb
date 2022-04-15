require 'sassc'

module Statics
  class Sass
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def path
      "src/#{name}.sass"
    end

    def build
      if exists?
        engine = ::SassC::Engine.new(File.read(path), syntax: :sass, style: :compressed)

        File.write "build/#{name}.css", engine.render
      end
    end

    def exists?
      File.exist? path
    end

    def print(indentation)
      puts "#{" " * (indentation * 3)}└─ Sass: #{path} #{valid}"
    end

    def valid
      if exists?
        Colors.in_green("✔")
      else
        Colors.in_red("✘")
      end
    end
  end
end
