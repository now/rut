# -*- coding: utf-8 -*-

module Rut::Streams::Outputs::Files::Local::POSIX::Existing::Backup
  class << self
    def rut(rut)
      rut.parent/('%s~' % rut.basename)
    end

    def create(actual)
      rut(actual.rut).tap{  |rut|
        backup rut, actual.io, actual.stat
        restore actual.io
      }
    end

    def backup(rut, input, stat)
      rut.delete_if_exists
      Rut::OS.open(rut.path, IO::CREAT | IO::EXCL | IO::WRONLY, stat.mode & 0777) do |output|
        output.stat.gid == stat.gid or
          output.chown(-1, stat.gid) rescue nil or
          output.chmod((stat.mode & 0707) | ((stat.mode & 07) << 3))
        Copy.new input, output
      end
    rescue SystemCallError, Rut::Error
      rut.try_delete
      raise Rut::CannotCreateBackupError, 'Backup file creation failed'
    end

    def restore(input)
      input.sysseek(0, IO::SEEK_SET)
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error seeking in file: %s')
    end
  end

private

  autoload :Copy, 'rut/streams/outputs/files/local/posix/existing/backup/copy'
end
