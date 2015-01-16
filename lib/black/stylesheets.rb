require 'sass'

module Black
  module Stylesheets
    SyntaxStylesheet = File.join(::Black.root, 'lib/black/templates/stylesheets/syntax.css.scss')
    DiffStylesheet = File.join(::Black.root, 'lib/black/templates/stylesheets/diff.css.scss')
    DefaultOptions = {
      syntax: :scss
    }

    def self.css(options={})
      template = File.open(DiffStylesheet).read
      template += File.open(SyntaxStylesheet).read

      render(template, options)
    end

    def self.syntax(options={})
      template = File.open(SyntaxStylesheet).read
      render(template, options)
    end

    def self.diff(options={})
      template = File.open(SyntaxStylesheet).read
      render(template, options)
    end

    private

    def self.render(template, options={})
      engine = Sass::Engine.new(template, DefaultOptions.merge(options))
      engine.render
    end
  end
end
