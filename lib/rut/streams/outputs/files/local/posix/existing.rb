# -*- coding: utf-8 -*-

module Rut::Streams::Outputs::Files::Local::POSIX::Existing
  autoload :Actual, 'rut/streams/outputs/files/local/posix/existing/actual'
  autoload :Backup, 'rut/streams/outputs/files/local/posix/existing/backup'
  autoload :Replacement, 'rut/streams/outputs/files/local/posix/existing/replacement'
  autoload :Temporary, 'rut/streams/outputs/files/local/posix/existing/temporary'

  class << self
    def new(rut, readable, etag, backup, flags)
      actual = Actual.new(rut, readable || backup, etag, flags)
      # TODO: make Backup a proper object, create it, pass it to temporary (for
      # path, then, if temporary wasn’t created and we have backup, create it.
      # (Or maybe?)
      temporary = Temporary.try_to_create(actual, readable, backup, flags)
      Backup.create actual unless temporary or not backup
      (temporary or
       Replacement.maybe_create(actual, readable, flags) or
       actual).extend(self)
    rescue
      # TODO: Close others here and don’t throw errors, so use try_simple_close
      actual.close if actual
      raise
    end
  end

  def close
    sync
    super
  ensure
    try_simple_close
  end

private

  def sync
    io.fsync
  rescue NotImplementedError
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error writing to file: %s')
  end
end
