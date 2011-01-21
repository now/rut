# -*- coding: utf-8 -*-

class Rut::Streams::Inputs::Files::Local
  include Rut::Streams::Inputs::File

  def initialize(io)
    super()
    @io = io
  end

private

  def super_close
    @io.close
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error closing file: %s')
  end

  def super_read(bytes)
    @io.sysread(bytes)
  rescue EOFError
    ''
  rescue Errno::EINTR
    retry
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error reading from file: %s')
  end
end
