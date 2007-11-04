module Typeraker

  # Takes care of running latex and related utilities. Gives helpful
  # information if input files are missing and also cleans up the output of
  # these utilities.
  module Runner
    class Base
      include Typeraker::Cli

      # The file to be run trough the latex process.
      attr_accessor :input_file

      # If true no messages is sendt to standard out. Defaults to false.
      attr_accessor :silent

      # The LaTeX executable. Defaults to plain `latex` if it's found on
      # the system.
      attr_accessor :executable

      # Contains a list of possible warnings after a run.
      attr_accessor :warnings

      # Contains a list of possible errors after a run.
      attr_accessor :errors

      def initialize(input_file, silent, executable)
        @input_file = input_file
        disable_stdout do
          @executable = executable if system "which #{executable}"
        end
        @silent = silent
        @errors = []

        if File.exists? @input_file
          run
        else
          error "Running of #@executable aborted. " +
                "Input file: #@input_file not found"
        end
      end

      def run
      end

      def feedback
        return if @silent
        unless @warnings.empty?
          notice "Warnings from #@executable:"
          @warnings.each do |message|
            warning message
          end
        end
        unless @errors.empty?
          notice "Errors from #@executable:"
          @errors.each do |message|
            error message
          end
        end
      end
    end

    class LaTeX < Base
      def initialize(input_file, silent=false, executable='latex')
        super
      end

      def run
        disable_stdinn do
          messages = /^(Overfull|Underfull|No file|Package \w+ Warning:)/
          run = `#@executable #@input_file`
          @warnings = run.grep(messages)
          lines = run.split("\n")
          while lines.shift
            if lines.first =~ /^!/
              3.times { @errors << lines.shift }
            end
          end
          feedback
        end
      end
    end

    class BibTeX < Base
      def initialize(input_file, silent=false, executable='bibtex')
        super
      end

      def run
        messages = /^I (found no|couldn't open)/
        @warnings = `#@executable #@input_file`.grep(messages)
        feedback
      end
    end

    class DviPs < Base
      def initialize(input_file, silent=false, executable='dvips')
        super
      end

      def run
        disable_stderr do
          @warnings = `#@executable -Ppdf #@input_file`.split("\n")
        end
        feedback
      end
    end

    class Ps2Pdf < Base
      def initialize(input_file, silent=false, executable='ps2pdf')
        super
      end

      def run
        disable_stderr do
          @warnings = `#@executable #@input_file`.split("\n")
        end
      end
    end
  end
end
