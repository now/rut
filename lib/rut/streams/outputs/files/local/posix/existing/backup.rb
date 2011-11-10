# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Backup
  class << self
    def prepare(actual, options = {})
      options[:backup] ? new(rut(actual.rut), actual.io, actual.stat) : nil
    end

    private

    def rut(rut)
      rut.parent/('%s~' % rut.basename)
    end
  end

  def initialize(rut, input, stat)
    @rut, @input, @stat = rut, input, stat
  end

  def call
    create_backup
    restore_input
  end

  attr_reader :rut

  private

  def create_backup
    @rut.delete_if_exists
    create_new_backup
  rescue SystemCallError, Rut::Error
    raise Rut::CannotCreateBackupError, 'Backup file creation failed'
  end

  def create_new_backup
    Rut::OS.open(@rut.path, IO::CREAT | IO::EXCL | IO::WRONLY, @stat.mode & 0777) do |output|
      output.stat.gid == @stat.gid or
        output.chown(-1, @stat.gid) rescue nil or
        output.chmod((@stat.mode & 0707) | ((@stat.mode & 07) << 3))
      Copy.new(@input, output).call
    end
  rescue SystemCallError
    @rut.try_delete
    raise
  end

  def restore_input
    @input.sysseek(0, IO::SEEK_SET)
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error seeking in file: %s')
  end

  class Copy
    def initialize(input, output)
      @input, @output = input, output
    end

    def call
      read_loop '*' * BufferSize
    end

    private

    BufferSize = 8192

    def read_loop(buffer)
      until (bytes_read = read(buffer)).zero?
        write_loop buffer[0...bytes_read]
      end
    end

    def read(buffer)
      @input.sysread BufferSize, buffer
      buffer.length
    rescue Errno::EINTR
      retry
    end

    def write_loop(buffer)
      begin buffer = buffer[write(buffer)..-1] end until buffer.empty?
    end

    def write(buffer)
      @output.syswrite(buffer)
    rescue Errno::EINTR
      retry
    end
  end
end
