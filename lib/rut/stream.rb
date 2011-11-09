# -*- coding: utf-8 -*-

module Rut::Stream
  def initialize
    @closed = false
    @pending = false
  end

  def close
    with_pending do begin yield ensure @closed = true end end unless closed?
    self
  end

  def closed?
    @closed
  end

  def must_be_open
    raise Rut::ClosedError, 'stream is already closed' if closed?
  end

  def with_pending
    must_be_open
    raise Rut::PendingError, 'stream has outstanding operation' if pending?
    @pending = true
    begin yield self ensure @pending = false end
  end

  def pending?
    @pending
  end
end
