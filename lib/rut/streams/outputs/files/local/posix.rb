# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX
  autoload :Close, 'rut/streams/outputs/files/local/posix/close'
  autoload :Existing, 'rut/streams/outputs/files/local/posix/existing'

  include Rut::Streams::Output

  class << self
    def append(rut, flags = Rut::Create::None)
      new(Rut::OS.open(rut.path,
                        IO::CREAT | IO::APPEND | IO::WRONLY,
                        flags & Rut::Create::Private ? 0600 : 0666),
          rut.path)
    rescue Errno::EINVAL
      raise Rut::InvalidNameError, 'Invalid filename'
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error opening file: %s')
    end

    def replace(rut, readable = false, etag = nil, backup = false, flags = Rut::Create::None)
      new(Rut::OS.open(rut.path,
                        IO::CREAT | IO::EXCL | (readable ? IO::RDWR : IO::WRONLY),
                        flags & Rut::Create::Private ? 0600 : 0666),
          rut.path)
    rescue Errno::EEXIST
      existing = Existing.new(rut, readable, etag, backup, flags)
      new(existing.io, rut.path, const_get(:Close).const_get(:Existing).new(existing))
    rescue Errno::EINVAL
      raise Rut::InvalidNameError, 'Invalid filename'
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error opening file: %s')
    end
  end

  def initialize(io, path, close = Close::Simple.new(io))
    super()
    @io, @path, @close = io, path, close
  end

private

  def super_write(buffer, bytes = nil)
    prefix = bytes.nil? ? buffer : buffer[0...bytes]
    begin
      @io.syswrite(prefix)
    rescue Errno::EINTR
      retry
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error writing to file: %s')
    end
  end

  def super_close
    @close.call
  ensure
    begin @io.close rescue SystemCallError end unless @io.closed?
  end
end
