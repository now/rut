# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Replacement
  class << self
    def maybe_create(actual, readable, flags)
      unless flags & Rut::Create::ReplaceDestination
        actual.truncate
        return nil
      end
      remove_actual
      Rut::Streams::Outputs::Files::Local::POSIX::File.new(actual.rut, flags, readable, IO::CREAT)
    end

  private

    def remove_actual
      actual.try_simple_close
      rut.delete
    rescue Rut::Error => e
      raise e, 'Error removing old file: %s' % e
    end
  end
end
