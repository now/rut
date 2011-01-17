# -*- coding: utf-8 -*-

module Rut::VFS::Rut
  def has_parent?(parent = nil)
    self.parent and (parent.nil? or parent == self.parent)
  end

  def info
    raise Rut::NotSupportedError, 'Info not supported'
  end

  def copy(destination, flags)
    if flags & Rut::Copy::DoNotFollowSymlinks and info.symlink?
      destination.make_symlink info.target
    elsif info.special?
      # FIXME: could try to recreate device nodes and others?
      raise Rut::NotSupportedError, 'Cannot copy special file'
    else
    end
    # copy attributes 
  end

  def read
    raise Rut::NotSupportedError, 'Read not supported'
  end

  def make_symlink(target)
    File.symlink(target, path)
  rescue Errno::EINVAL
    raise Rut::InvalidNameError, 'Invalid filename'
  rescue Errno::EPERM, NotImplementedError
    raise Rut::NotSupportedError, 'Filesystem does not support symlinks'
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error making symbolic link: %s')
  end
end
