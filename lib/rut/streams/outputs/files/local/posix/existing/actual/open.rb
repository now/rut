# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Actual::Open
  def initialize(rut, readable, flags)
    @rut, @readable, @flags = rut, readable, flags
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
    [try_open IO::NOFOLLOW, false]
  rescue Errno::ELOOP
    [try_open, true]
  end

  def open_with_racy_symlink_check
    [try_open, File.symlink?(@rut.path)]
  end

  def try_open(flags = 0)
    Rut::OS.open(@rut.path,
                 IO::CREAT | (@readable ? IO::RDWR : IO::WRONLY) | flags,
                 @flags & Rut::Create::Private ? 0600 : 0666)
  end
end
