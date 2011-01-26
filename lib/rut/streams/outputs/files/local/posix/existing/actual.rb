# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Actual
  include Rut::Streams::Outputs::Files::Local::POSIX::Instance

  def initialize(rut, readable, etag, flags)
    @io, @symlink = Open.new(rut, readable, flags).call
    raise Rut::IsDirectoryError, 'Target file is a directory' if stat.directory?
    raise Rut::NotRegularFileError, 'Target file is not a regular file' unless stat.file?
    raise Rut::WrongEtagError, 'The file was externally modified' if Rut::Info.etag(stat) != etag
  rescue
    try_simple_close
    raise
  end

  def truncate
    io.truncate 0
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error truncating file: %s')
  end

  def symlink?
    @symlink
  end

  def stat
    @stat ||= io.stat
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error stating file: %s')
  end

private

  autoload :Open, 'rut/streams/outputs/files/local/posix/existing/actual/open'
end
