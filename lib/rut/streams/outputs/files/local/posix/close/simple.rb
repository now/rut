# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Close::Simple
  def initialize(io)
    @io = io
  end

  def call
    tag.tap{ close }
  end

private

  def tag
    stat = @io.stat
    # TODO: Implement this
    # create_etag(stat)
    nil
  rescue SystemCallError
  end

  def close
    @io.close
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error closing file: %s')
  end
end
