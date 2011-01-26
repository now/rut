# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::File
  include Rut::Streams::Output::Files::Local::POSIX::Instance

  class << self
    # TODO: Move Rut::OS.open here.

    def close(io)
      stat = io.stat rescue nil
      io.close
      stat ? Rut::Info.etag(stat) : nil
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error closing file: %s')
    end
  end

  def initialize(rut, readable, flags, o_flags = IO::CREAT | IO::EXCL)
    @io = Rut::OS.open(rut.path,
                       o_flags | (readable ? IO::RDWR : IO::WRONLY),
                       flags & Rut::Create::Private ? 0600 : 0666)
  rescue Errno::EINVAL
    raise Rut::InvalidNameError, 'Invalid filename'
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error opening file: %s')
  end
end
