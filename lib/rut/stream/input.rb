# -*- coding: utf-8 -*-

module Rut::Stream::Input
  def initialize
    @closed = false
    @pending = false
  end

  def close
    return self if closed?
    with_pending do
      begin
        super_close
      ensure
        @closed = true
      end
    end
    self
  end

  def closed?
    @closed
  end

  def with_pending
    raise Rut::ClosedError, 'Stream is already closed' if closed?
    raise Rut::PendingError, 'Stream has outstanding operation' if pending?
    @pending = true
    begin
      yield self
    ensure
      @pending = false
    end
  end

  def pending?
    @pending
  end

  def read(bytes)
    raise Rut::ArgumentError, 'Cannot read a negative number of bytes: %d' % bytes if bytes < 0
    with_pending do
      super_read(bytes)
    end
  end
end
