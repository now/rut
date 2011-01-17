# -*- coding: utf-8 -*-

class Rut
  autoload :Copy, 'rut/copy'
  autoload :Info, 'rut/info'
  autoload :Stream, 'rut/stream'
  autoload :VFS, 'rut/vfs'

  class << self
    def new_for_path(path)
      new(path)
    end

  private

    def windows?
      Config::CONFIG['target_os'] == 'mingw32'
    end
  end

  def initialize(path)
    @path = self.class.canonicalize(path)
  end

  attr_reader :path

  def basename
    self.class.basename(path)
  end

  def parent
    root, path = self.class.split_root(path)
    return nil unless root
    self.class.dirname(path)
  end

  require 'rut/error'
end
