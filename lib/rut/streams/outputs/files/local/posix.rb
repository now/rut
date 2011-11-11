# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX
  require_relative 'posix/existing.rb'
  require_relative 'posix/file.rb'

  class << self
    def create(rut, options = {})
      new(File.create(rut, options))
    end

    def append(rut, options = {})
      new(File.append(rut, options))
    end

    def replace(rut, options = {})
      new(File.create(rut, options))
    rescue Rut::ExistsError
      new(Existing.replace(rut, options))
    end
  end

  def initialize(file)
    @file = file
    @etag = nil
  end

  def write(buffer, bytes = nil)
    prefix = bytes.nil? ? buffer : buffer[0...bytes]
    begin
      @file.write(prefix)
    rescue Errno::EINTR
      retry
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error writing to file: %s')
    end
  end

  def flush
  end

  def close
    @etag = @file.close
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error closing file: %s')
  end
end
