# -*- coding: utf-8 -*-

module Rut::Streams::Input
  include Rut::Stream

  def close
    return self if closed?
    with_pending do
      begin super_close ensure @closed = true end
    end
    self
  end

  def read(bytes)
    raise Rut::ArgumentError, 'Cannot read a negative number of bytes: %d' % bytes if bytes < 0
    with_pending do
      super_read(bytes)
    end
  end
end
