# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Close::Existing
  def initialize(existing)
    @io, @path, @temporary, @backup = existing.io, existing.path, existing.temporary, existing.backup
  end

  def call
    sync
    move_temporary_in_place
    Rut::Streams::Outputs::Files::Local::POSIX::Close::Simple.new(@io).call
  end

private

  def sync
    @io.fsync
  rescue NotImplementedError
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error writing to file: %s')
  end

  def move_temporary_in_place
    move_backup_in_place
    File.rename(@temporary.path, @path)
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error renaming temporary file: %s')
  end

  def move_backup_in_place
    return unless @backup
    delete_backup
    link_or_rename_to_backup
  end

  def delete_backup
    @backup.delete
  rescue Rut::NotFoundError
  rescue Rut::Error => e
    raise Rut::CannotCreateBackup, 'Error removing old backup link: %s' % e
  end

  def link_or_rename_to_backup
    File.link(@path, @backup.path)
  rescue NotImplementedError, SystemCallError
    rename_to_backup
  end

  def rename_to_backup
    File.rename(@path, @backup.path)
  rescue SystemCallError => e
    raise Rut::CannotCreateBackup, 'Error creating backup copy: %s' % e
  end
end
