require 'erb'
require 'rouge'

module Black
  module HTMLView
    DefaultData = {
      template_path: File.join(::Black.root, 'lib/black/templates/diff.html.erb'),
    }

    def self.render(data={})
      data = DefaultData.merge(data)
      context = Context.new(data)
      template = File.read(data[:template_path])
      ERB.new(template).result(context.get_binding)
    end

    class Context
      def initialize(data)
        data.each do |name, value|
          self.class.class_eval do
            define_method(name) { value }
          end
        end
      end

      # return syntax-highlighted version of the line
      def highlight(line)
        line.deletion? ?
          older[line.old_line_number-1] :
          newer[line.new_line_number-1]
      end

      def content
        @content ||= rogueify(diff.newer)
      end


      def get_binding
        binding
      end

      private

      # The source needs to be syntax-highlighted as a whole because it
      # can have multiple syntax types e.g. index.html contains HTML/CSS/JS.
      # highlighting lines one-by-one misses the context and doesn't work.
      #
      # Both older and newer sources are highlighted. The diffed line in question
      # then references its old/new line number to grab the correct syntax-highlighted line.

      # Collection of syntax-highlighted lines from older source
      def older
        @older ||= rogueify(diff.older).lines.to_a
      end

      # Collection of syntax-highlighted lines from newer source
      def newer
        @newer ||= rogueify(diff.newer).lines.to_a
      end

      def rogueify(source)
        lexer = Rouge::Lexer.guess({ filename: diff.filename, source: source })
        formatter = Rouge::Formatters::HTML.new(wrap: false)
        formatter.format(lexer.new.lex(source))
      end
    end
  end
end
