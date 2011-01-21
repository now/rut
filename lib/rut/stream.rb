# -*- coding: utf-8 -*-

module Rut::Stream
  def initialize
    @closed = false
    @pending = false
  end

  def closed?
    @closed
  end

  def with_pending
    raise Rut::ClosedError, 'Stream is already closed' if closed?
    raise Rut::PendingError, 'Stream has outstanding operation' if pending?
    @pending = true
    begin yield self ensure @pending = false end
  end

  def pending?
    @pending
  end
end
