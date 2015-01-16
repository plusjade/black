require 'erb'

module Black
  # rack compatable preview generator
  # Usage:
  # Create a new rack application 
  # in config.ru:
  #   require 'rack'
  #   require 'black'
  #
  #   diff = Black::Diff.new('older string', 'newer string', 'file-name.html')
  #   content = Black::HTMLView.render(diff: diff)
  #   run Black::Preview.new(content)
  # Then run the rack app:
  # $ rackup config.ru
  class Preview
    Template = <<-TEXT
    <!doctype html>
    <html>
    <head>
      <style>
        html, body { margin: 0; padding: 0; }
        <%= css %>
      </style>
    </head>
    <body>
      <%= content %>
    </body>
    </html>
    TEXT

    def initialize(content, css=nil)
      @css = css
      @content = content
    end

    def call(env)
      @css ||= Black::Stylesheets.css({ style: :compressed })

      context = Context.new(@content, @css)
      output = ::ERB.new(Template).result(context.get_binding)

      [200, {'Content-Type' => 'text/html'}, [output]]
    end

    class Context < Struct.new(:content, :css)
      def get_binding
        binding
      end
    end
  end
end
