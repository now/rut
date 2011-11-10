# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::File
  class << self
    def append(rut, options = {})
      open(rut, IO::APPEND | IO::WRONLY, options)
    end

    def create(rut, options = {})
      open(rut, IO::EXCL | (options[:readable] ? IO::RDWR : IO::WRONLY), options)
    end

    def create_or_open(rut, options = {})
      open(rut, options[:readable] ? IO::RDWR : IO::WRONLY, options)
    end

    private

    def open(rut, flags, options = {})
      new(Rut::OS.open(rut.path, IO::CREAT | flags, options[:private] ? 0600 : 0666))
    rescue Errno::EINVAL
      raise Rut::InvalidNameError, 'Invalid filename'
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error opening file: %s')
    end
  end

  def initialize(io)
    @io = io
  end

  def write(buffer)
    @io.syswrite(buffer)
  end

  def close
    stat = @io.stat rescue nil
    @io.close
    stat ? Rut::Info.etag(stat) : nil
  end
end
