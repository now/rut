# -*- coding: utf-8 -*-

module Rut::Streams::Input
  include Rut::Stream

  def close
    super{ @base.close }
  end

  def read(bytes)
    raise Rut::ArgumentError,
      'cannot read a negative number of bytes: %d' % bytes if bytes < 0
    with_pending{ @base.read(bytes) }
  end
end
