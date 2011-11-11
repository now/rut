# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing
  require_relative 'existing/actual.rb'
  require_relative 'existing/backup.rb'

  class << self
    def replace(rut, options = {})
      actual = Actual.new(rut, options)
      begin
        create_temporary(actual, options) or actual.maybe_replace
      rescue
        actual.try_close
        raise
      end
    end

    private

    def create_temporary(actual, options)
      backup = Backup.prepare(actual, options)
      try_create_temporary(actual, backup, options) or (backup.call; nil)
    end

    def try_create_temporary(actual, backup, options = {})
      return nil unless options[:replace] or (actual.stat.nlink < 2 and not actual.symlink?)
      new(actual.rut, actual.stat, backup.rut, options).tap{ actual.try_close }
    rescue Rut::Error
      nil
    end
  end

  def initialize(actual, stat, backup, options = {})
    @io, rut = Open.new(actual.parent/'.rutoutput-XXXXXX', stat, options).call
    @file = Rut::Streams::Outputs::Files::Local::POSIX::File.new(@io)
    @close = Close.new(rut, actual, backup)
  end

  def write(buffer)
    @file.write(buffer)
  end

  def close
    begin
      sync
      @close.call
    rescue
      try_close
      raise
    end
    @file.close
  end

  private

  def sync
    @io.fsync
  rescue NotImplementedError
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error writing to file: %s')
  end

  def try_close
    begin @io.close rescue SystemCallError end
  end

  class Open
    def initialize(rut, stat, options)
      @stat, @options = stat, options
      offset = rut.path.rindex(Pattern) or
        raise ArgumentError, 'template does not contain %s: %s' % [Pattern, rut.path]
      @before = rut.path[0...offset]
      @after = rut.path[offset+Pattern.length..-1]
    end

    def call
      open.tap{ |io, rut|
        set_owner_and_permissions io, rut unless @options[:replace]
      }
    end

    private

    Letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.freeze
    Pattern = 'XXXXXX'.freeze
    Tries = 100

    def open
      value = next_value
      Tries.times do
        result = try(value) and return result
        value += 7777
      end
      raise Errno::EEXIST
    end

    def next_value
      @@counter ||= 0
      time = Time.now
      ((time.tv_usec ^ time.tv_sec) + @@counter).tap{ @@counter += 1 }
    end

    def try(value)
      path = @before
      Pattern.length.times do
        path << Letters[value % Letters.length]
        value /= Letters.length
      end
      path << @after
      [Rut::OS.open(path,
                    IO::CREAT | IO::EXCL |
                      (@options[:readable] ? IO::RDWR : IO::WRONLY),
                    @options[:private] ? 0600 : 0666),
       Rut.new_for_path(path)]
    rescue Errno::EEXIST
      nil
    end

    def set_owner_and_permissions(io, rut)
      io.chown @stat.uid, @stat.gid
      io.chmod @stat.mode
    rescue SystemCallError => e
      return if already_has_same_owner_and_permissions? io
      begin io.close rescue SystemCallError end
      rut.try_to_delete
      raise Rut::Error.from(e, 'Error creating temporary file: %s')
    end

    def already_has_same_owner_and_permissions?(io)
      a = (io.stat rescue nil) and
        a.uid == @stat.uid and a.gid == @stat.gid and a.mode == @stat.mode
    end
  end

  class Close
    def initialize(temporary, actual, backup = nil)
      @temporary, @actual, @backup = temporary, actual, backup
    end

    def call
      move_actual_to_backup
      move_temporary_to_actual
    end

    private

    # TODO: This should be moved to Backup.
    def move_actual_to_backup
      return unless @backup
      delete_backup
      link_or_rename_actual_to_backup
    end

    def delete_backup
      @backup.delete
    rescue Rut::NotFoundError
    rescue Rut::Error => e
      raise Rut::CannotCreateBackup, 'Error removing old backup link: %s' % e
    end

    def link_or_rename_actual_to_backup
      File.link @actual.path, @backup.path
    rescue NotImplementedError, SystemCallError
      rename_actual_to_backup
    end

    def rename_actual_to_backup
      File.rename @actual.path, @backup.path
    rescue SystemCallError => e
      raise Rut::CannotCreateBackup, 'Error creating backup copy: %s' % e
    end

    # TODO: Use @rut.rename or whatever.
    def move_temporary_to_actual
      File.rename @temporary.path, @actual.path
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'cannot rename temporary file: %s: %%s' % @temporary.path)
    end
  end
end
