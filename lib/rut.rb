# -*- coding: utf-8 -*-

class Rut
  autoload :Info, 'rut/info'
  autoload :OS, 'rut/os'
  autoload :Stream, 'rut/stream'
  autoload :Streams, 'rut/streams'
  autoload :VFS, 'rut/vfs'

  class << self
    def new_for_path(path)
      (windows? ?
        VFS::Local::Windows::Rut :
        VFS::Local::POSIX::Rut).new(path)
    end

    def windows?
      RbConfig::CONFIG['target_os'] == 'mingw32'
    end
  end

  require_relative 'rut/error.rb'
end
