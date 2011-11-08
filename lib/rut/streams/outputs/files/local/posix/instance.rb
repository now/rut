# -*- coding: utf-8 -*-

module Rut::Streams::Outputs::Files::Local::POSIX::Instance
  def close
    stat = io.stat rescue nil
    io.close
    stat ? Rut::Info.etag(stat) : nil
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error closing file: %s')
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
