# -*- coding: utf-8 -*-

module Rut::Streams::Output
  include Rut::Stream

  def initialize
    super
    @closing = false
  end

  def write(buffer, bytes = nil)
    raise Rut::ArgumentError, 'Cannot write a negative number of bytes: %d' % bytes if bytes and bytes < 0
    return 0 if bytes and bytes.zero?
    with_pending do
      super_write(buffer, bytes)
    end
  end

  def close
    return self if closed?
    with_pending do
      begin
        with_closing do
          begin
            flush
          rescue
            super_close rescue nil
            raise
          end
          super_close
        end
      ensure
        @closed = true
      end
    end
    self
  end

  def closed?
    @closed
  end

  def flush
  end

  def with_closing
    @closing = true
    begin yield self ensure @closing = false end
  end
end
