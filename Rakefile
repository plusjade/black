$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), *%w[lib]))
require 'rubygems'
require 'rake'
require 'bundler'
require 'black/version'

name = Dir['*.gemspec'].first.split('.').first
gemspec_file = "#{name}.gemspec"
gem_file = "#{name}-#{ Black::VERSION }.gem"

task :release => :build do
  sh "git commit --allow-empty -m 'Release #{Black::VERSION}'"
  sh "git tag v#{Black::VERSION}"
  sh "git push origin master --tags"
  sh "git push origin v#{Black::VERSION}"
  sh "gem push pkg/#{name}-#{Black::VERSION}.gem"
end

task :build do
  sh "mkdir -p pkg"
  sh "gem build #{ gemspec_file }"
  sh "mv #{ gem_file } pkg"
end