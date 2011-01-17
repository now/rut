# -*- coding: utf-8 -*-

class Rut::Stream::Inputs::Files::Local
  include Rut::Stream::Inputs::File

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
    loop do
      begin
        return @io.sysread(bytes)
      rescue EOFError
        return ''
      rescue Errno::EINTR
      end
    end
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error reading from file: %s')
  end
end
