# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Actual
  def initialize(rut, readable, etag, flags)
    @io, @symlink = Open.new(rut, readable, etag, flags).call
    raise Rut::IsDirectoryError, 'Target file is a directory' if stat.directory?
    raise Rut::NotRegularFileError, 'Target file is not a regular file' unless stat.file?
    # TODO: Implement this.
    raise Rut::WrongEtagError, 'The file was externally modified' if etag
    # and etag != Rut::Info::Local.create_etag(original_stat)
  rescue
    close
    raise
  end

  def close
    return unless defined? @io and @io
    begin @io.close rescue SystemCallError end
    @io = nil
  end

  attr_reader :io

  def symlink?
    @symlink
  end

  def stat
    @stat ||= @io.stat
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error stating file: %s')
  end

private

  autoload :Open, 'rut/streams/outputs/files/local/posix/existing/actual'
end
