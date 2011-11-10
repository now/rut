# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Actual
  def initialize(rut, options = {})
    @rut, @options = rut, options
    @io, @symlink = Open.new(rut, options).call
    begin
      raise Rut::IsDirectoryError,
        'Target file is a directory' if stat.directory?
      raise Rut::NotRegularFileError,
        'Target file is not a regular file' unless stat.file?
      raise Rut::WrongEtagError,
        'The file was externally modified' if
          options[:etag] and Rut::Info.etag(stat) != options[:etag]
    rescue
      try_close
      raise
    end
  end

  def symlink?
    @symlink
  end

  def stat
    @stat ||= io.stat
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error stating file: %s')
  end

  def try_close
    io.close
    self
  rescue SystemCallError
  end

  def maybe_replace
    if @options[:replace]
      remove
      Rut::Streams::Outputs::Files::Local::POSIX::File.create_or_open(rut, @options)
    else
      truncate
      Rut::Streams::Outputs::Files::Local::POSIX::File.new(io)
    end
  end

  attr_reader :io, :rut

  private

  def remove
    try_close
    rut.delete
  rescue Rut::Error => e
    raise e, 'Error removing old file: %s' % e
  end

  def truncate
    io.truncate 0
    self
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error truncating file: %s')
  end

  class Open
    def initialize(rut, options = {})
      @rut, @options = rut, options
    end

    def call
      defined?(IO::NOFOLLOW) ?
        open_with_sane_symlink_check :
        open_with_racy_symlink_check
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error opening file: %s')
    end

    private

    def open_with_sane_symlink_check
      [try_open(IO::NOFOLLOW), false]
    rescue Errno::ELOOP
      [try_open, true]
    end

    def open_with_racy_symlink_check
      [try_open, File.symlink?(@rut.path)]
    end

    # TODO: Why not use (the gist of)
    # Rut::Streams::Outputs::Files::Local::POSIX::File.open?
    def try_open(flags = 0)
      Rut::OS.open(@rut.path,
                   IO::CREAT | flags |
                     (@options[:readable] || @options[:backup] ? IO::RDWR : IO::WRONLY),
                   @options[:private] ? 0600 : 0666)
    end
  end
end
