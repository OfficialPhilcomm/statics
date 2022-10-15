require "tty-option"
require_relative "../settings"
require_relative "../builder"
require_relative "../utils/colors"

module Staticz
  class BuildCommand
    include TTY::Option

    usage do
      program "staticz"
      command "build"

      description "Compile the project"
    end

    flag :verbose do
      short "-v"
      long "--verbose"
      desc "Use verbose output"
    end

    flag :help do
      short "-h"
      long "--help"
      desc "Print this page"
    end

    option :environment do
      desc "Set the environment"
      short "-e"
      long "--environment environment"

      default :production
      permit [:development, :production]
      convert :symbol
    end

    def run
      if params[:help]
        print help
        exit
      end

      if !params[:environment]
        puts "Environment must either be development or production"
        exit 1
      end

      if params[:verbose]
        Staticz::Settings.verbose!
      end

      Staticz::Settings.set_environment(params[:environment])

      Staticz::Builder.new(listener_class: BuildListener)
    end
  end

  class BuildListener
    def initialize(compilable)
      if Staticz::Settings.verbose?
        puts "Compiling #{generate_text(compilable)}"
      else
        @spinner = TTY::Spinner.new(
          "[:spinner] #{generate_text(compilable)}",
          format: :classic,
          success_mark: Colors.in_green("✔")
        )

        @spinner.auto_spin
      end
    end

    def generate_text(compilable)
      if compilable.is_a? Staticz::JSBundle
        compilable.name
      else
        "#{compilable.source_path} -> #{compilable.build_path}"
      end
    end

    def finish
      @spinner.success("(successful)") if !Staticz::Settings.verbose?
    end
  end
end
