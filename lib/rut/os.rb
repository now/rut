# -*- coding: utf-8 -*-

module Rut::OS
  class << self
    def open(path, flags, mode = 0)
      flags |= IO::BINARY if defined? IO::BINARY
      file = File.new(IO.sysopen(path, flags, mode), flags)
      return file unless block_given?
      begin
        yield file
      ensure
        begin file.close rescue SystemCallError end unless file.closed?
      end
    end
  end
end
