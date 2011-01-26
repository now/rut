# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX
  autoload :Existing, 'rut/streams/outputs/files/local/posix/existing'
  autoload :File, 'rut/streams/outputs/files/local/posix/file'

  class << self
=begin
    def append(rut, flags = Rut::Create::None)
      new(Rut::OS.open(rut.path,
                        IO::CREAT | IO::APPEND | IO::WRONLY,
                        flags & Rut::Create::Private ? 0600 : 0666),
          rut.path)
    rescue Errno::EINVAL
      raise Rut::InvalidNameError, 'Invalid filename'
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error opening file: %s')
    end
=end

    def replace(rut, readable = false, etag = nil, backup = false, flags = Rut::Create::None)
      extended_new(File.new(rut, readable, flags))
    rescue Rut::ExistsError
      extended_new(Existing.new(rut, readable, etag, backup, flags))
    end

  private

    def extended_new(file)
      new(file).extend(Rut::Streams::Output)
    end
  end

  def initialize(file)
    super()
    @file = file
    @etag = nil
  end

private

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

  def close
    @etag = @file.close
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error closing file: %s')
  end
end
