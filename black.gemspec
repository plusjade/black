$LOAD_PATH.unshift 'lib'
require 'black/version'

Gem::Specification.new do |s|
  s.name              = "black"
  s.version           = Black::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.license           = "http://www.opensource.org/licenses/MIT"
  s.summary           = 'Black parses diff output to render a syntax-highlighted diff view in HTML'
  s.homepage          = "https://github.com/plusjade/black"
  s.email             = "plusjade@gmail.com"
  s.authors           = ['Jade Dominguez']
  s.description       = 'Black parses diff output to render a syntax-highlighted diff view in HTML'

  s.add_dependency 'rouge', "~> 1"
  s.add_dependency 'sass', "~> 3"

  s.files = `git ls-files`.
              split("\n").
              sort.
              reject { |file| file =~ /^(\.|rdoc|pkg|coverage)/ }
end

