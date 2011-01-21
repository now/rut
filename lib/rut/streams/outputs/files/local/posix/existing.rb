# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing
  autoload :Actual, 'rut/streams/outputs/files/local/posix/existing/actual'
  autoload :Backup, 'rut/streams/outputs/files/local/posix/existing/backup'
  autoload :Replacement, 'rut/streams/outputs/files/local/posix/existing/replacement'
  autoload :Temporary, 'rut/streams/outputs/files/local/posix/existing/temporary'

  def initialize(rut, readable, etag, backup, flags)
    @actual = Actual.new(rut, readable || backup, etag, flags)
    @temporary = Temporary.try_create(@actual, flags, readable)
    # TODO: Can test whether actual has been closed or not instead
    unless @temporary
      @backup = Backup.create(@actual) if backup
      @replacement = Replacement.maybe_create(@actual, flags, readable) or
        truncate
    end
  rescue
    @actual.close if defined? @actual
    raise
  end

  attr_reader :temporary, :backup

  def path
    @rut.path
  end

  def io
    @actual.io or (@replacement and @replacement.io) or @temporary.io
  end

private

  def truncate
    io.truncate 0
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error truncating file: %s')
  end
end
