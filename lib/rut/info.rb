# -*- coding: utf-8 -*-

class Rut::Info
  class << self
    def new_for_rut(rut)
      new_for_path(rut.path)
    end

    def etag(stat)
      time = stat.mtime
      '%u:%u' % [time.sec, time.usec]
    end

  private

    def new_for_path(path)
      new(path, File.lstat(path))
    end
  end

  def initialize(path, stat)
    @path, @stat = path, stat
  end

  def symlink?
    @stat.symlink?
  end

  def target
    symlink? ? File.readlink(@path) : nil
  rescue NotImplementedError
    nil
  end

  def special?
    stat.chardev? or stat.blockdev? or stat.pipe? or stat.socket?
  end

  def etag
    self.class.etag(@stat)
  end
end
