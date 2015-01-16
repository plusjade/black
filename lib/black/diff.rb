module Black
  class Diff
    # wrapper to execute `diff` in the shell.
    # Reimplement this to suit your own platform needs
    def self.execute(*command_args)
      `diff #{ command_args.join(' ') }`
    end

    include Enumerable

    attr_reader :older, :newer, :filename

    def initialize(older, newer, filename=nil)
      @older = older
      @newer = newer
      @filename = filename
    end

    def each
      if block_given?
        diff_parsed.each do |line|
          yield line
        end
      else
        diff_parsed.enum_for(:each) 
      end
    end

    # diff two strings using unix 'diff' command
    def execute
      files = [Tempfile.new('black'), Tempfile.new('black')]
      files.first.write(@older)
      files.last.write(@newer)
      files.each { |a| a.read }

      args = [files.first.path, files.last.path] + OutputParser.diff_options

      Diff.execute(args)
    ensure
      files.each do |file|
        if file && File.exist?(file.path)
          file.close
          file.unlink
        end
      end
    end

    def diff_parsed
      OutputParser.parse(execute.enum_for(:lines))
    end

    module OutputParser
      # `diff` command arguments to format the output
      def self.diff_options
        %w(-u)
      end

      # Parse the diff output
      def self.parse(diff_enumerator)
        Enumerator.new do |y|
          index = 0
          old_line_number = 1
          new_line_number = 1

          diff_enumerator.each do |line|
            type = identify_type(line)
            next if type == 'file-header'

            if type == "metadata"
              old_line_number = line.match(/\-[0-9]*/)[0].to_i.abs rescue 0
              new_line_number = line.match(/\+[0-9]*/)[0].to_i.abs rescue 0
            end

            d = {
              "type" => type,
              "index" => index,
              "old_line_number" => old_line_number,
              "new_line_number" => new_line_number,
              "content" => line
            }

            y.yield Line.new(d)

            index += 1
            new_line_number += 1 if %w(addition unchanged).include?(type)
            old_line_number += 1 if %w(deletion unchanged).include?(type)
          end
        end
      end

      def self.identify_type(line)
        if line.start_with?('---', '+++')
          "file-header"
        elsif line[0] == "+"
          "addition"
        elsif line[0] == "-"
          "deletion"
        elsif line.match(/^@@ -/)
          "metadata"
        else
          "unchanged"
        end
      end
    end

    # Nicer line API for views
    class Line
      def initialize(line)
        @line = line
      end

      def changed?
        ['addition', 'deletion'].include? @line['type']
      end

      def deletion?
        type == 'deletion'
      end

      def content
        @content ||= @line['content'].slice(/^.{1}/, @line['content'].length)
      end

      def type
        @line['type']
      end

      def new_line_number
        type == 'deletion' ? nil : @line['new_line_number']
      end

      def old_line_number
        type == 'addition' ? nil : @line['old_line_number']
      end
    end
  end
end
