# -*- coding: utf-8 -*-

module Rut::Streams::Output
  include Rut::Stream

  def initialize
    super
    @closing = false
  end

  def write(buffer, bytes = nil)
    raise Rut::ArgumentError,
      'cannot write a negative number of bytes: %d' % bytes if bytes and bytes < 0
    return 0 if bytes and bytes.zero?
    with_pending{ @base.write(buffer, bytes) }
  end

  def flush
    with_pending{ @base.flush }
  end

  def close
    super{
      with_closing do
        begin
          @base.flush
        rescue
          @base.close rescue nil
          raise
        end
        @base.close
      end
    }
  end

  private

  def with_closing
    @closing = true
    begin yield(self) ensure @closing = false end
  end
end
