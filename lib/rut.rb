# -*- coding: utf-8 -*-

class Rut
  autoload :Copy, 'rut/copy'
  autoload :Create, 'rut/create'
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
      Config::CONFIG['target_os'] == 'mingw32'
    end

  private

    def def_enum(enum, *names)
      modul = const_set(enum, Module.new)
      names.each_with_index do |name, index|
        modul.const_set name, 1 << index - 1
      end
      modul
    end
  end

  require 'rut/error'
end
