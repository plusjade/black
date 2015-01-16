# encoding: UTF-8
Encoding.default_internal = 'UTF-8'

require 'fileutils'

module Black
  Root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  def self.root ; Root ; end
end

FileUtils.cd(path = File.join(File.dirname(__FILE__), 'black')) do
  Dir[File.join('**', '*.rb')].each { |f| require File.join(path, f) }
end
