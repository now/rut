# -*- coding: utf-8 -*-

class Rut::Streams::Inputs::Files::Local
  class << self
    def open(path)
      begin
        io = Rut::OS.open(path, IO::RDONLY)
      rescue SystemCallError => e
        raise Rut::Error.from(e, 'Error opening file: %s')
      end
      if (io.stat.directory? rescue nil)
        io.close
        raise Rut::IsDirectoryError, 'Cannot open directory'
      end
      new(io, path)
    end
  end

  def initialize(io, path = nil)
    @io, @path = io, path
  end

  def close
    @io.close
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error closing file: %s')
  end

  def read(bytes)
    @io.sysread(bytes)
  rescue EOFError
    ''
  rescue Errno::EINTR
    retry
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error reading from file: %s')
  end
end
