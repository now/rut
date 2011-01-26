# -*- coding: utf-8 -*-

module Rut::Streams::Outputs::Files::Local::POSIX::Existing::Temporary::Instance
private

  def rearrange_actual_and_temporary
    move_actual_to_backup
    move_temporary_to_actual
  end

  def move_actual_to_backup
    return unless @backup
    delete_backup
    link_or_rename_actual_to_backup
  end

  def move_temporary_to_actual
    File.rename @temporary.path, @actual.path
  rescue SystemCallError => e
    raise Rut::Error.from(e, 'Error renaming temporary file: %s')
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
end
