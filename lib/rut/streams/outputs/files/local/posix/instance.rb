# -*- coding: utf-8 -*-

module Rut::Streams::Outputs::Files::Local::POSIX::Instance
  def close
    Rut::Streams::Outputs::Files::Local::POSIX::File.close(io)
  end

  def try_simple_close
    begin io.close rescue SystemCallError end unless io.closed?
  end

  def write(buffer)
    io.syswrite(buffer)
  end

private

  attr_reader :io
end
