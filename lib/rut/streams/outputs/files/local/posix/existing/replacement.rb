# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Replacement
  class << self
    def maybe_create(actual, flags, readable)
      return nil unless flags & Rut::Create::ReplaceDestination
      actual.close
      new(actual.rut, flags, readable)
    end
  end

  def initialize(rut, flags, readable)
    begin
      rut.delete
    rescue Rut::Error => e
      raise e, 'Error removing old file: %s' % e
    end
    begin
      @io = Rut::OS.open(rut.path,
                         IO::CREAT | (readable ? IO::RDWR : IO::WRONLY),
                         flags & Rut::Create::Private ? 0600 : 0666)
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error opening file: %s')
    end
  end

  attr_reader :io
end
