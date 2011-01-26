# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Backup::Copy
  def initialize(input, output)
    @input, @output = input, output
    read_loop '*' * BufferSize
  end

private

  BufferSize = 8192

  def read_loop(buffer)
    until (bytes_read = read(buffer)).zero?
      write_loop buffer[0...bytes_read]
    end
  end

  def read(buffer)
    @input.sysread BufferSize, buffer
    buffer.length
  rescue Errno::EINTR
    retry
  end

  def write_loop(buffer)
    begin buffer = buffer[write(buffer)..-1] end until buffer.empty?
  end

  def write(buffer)
    @output.syswrite(buffer)
  rescue Errno::EINTR
    retry
  end
end
