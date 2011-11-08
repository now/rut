# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Temporary
  include Rut::Streams::Outputs::Files::Local::POSIX::Instance
  include Instance

  class << self
    def try_to_create(actual, readable, backup, flags)
      return nil unless flags & Rut::Create::ReplaceDestination or (actual.stat.nlink < 2 and not actual.symlink?)
      new(actual.rut, readable, backup, flags, actual.stat).tap{ actual.try_simple_close }
    rescue Rut::Error
      nil
    end
  end

  # TODO: backup should be passed in.
  def initialize(rut, flags, readable, backup, flags, stat)
    @actual = rut
    @backup = backup ? Rut::Streams::Outputs::Files::Local::POSIX::Existing::Backup.rut(actual) : nil
    @io, @rut = Open.open(@actual.parent/'.rutoutput-XXXXXX', readable, flags)
    set_owner_and_permissions flags, stat
  rescue SystemCallError, Rut::Error => e
    try_simple_close
    @rut.try_to_delete if defined? @rut
    raise Rut::Error.from(e, 'Error creating temporary file: %s')
  end

  # TODO: super must come before the rearrangement.  How do we separate these?
  # Damn it!  I’m sick of this.
  def close
    rearrange_actual_and_temporary
    super
  end

private

  autoload :Instance, 'rut/streams/outputs/files/local/posix/existing/temporary/instance'
  autoload :Open, 'rut/streams/outputs/files/local/posix/existing/temporary/open'

  def set_owner_and_permissions(flags, stat)
    return if flags & Rut::Create::ReplaceDestination
    io.chown stat.uid, stat.gid
    io.chmod stat.mode
  rescue SystemCallError => e
    raise unless already_has_same_owner_and_permissions? stat
  end

  def already_has_same_owner_and_permissions?(b)
    a = (io.stat rescue nil) and
      a.uid == b.uid and a.gid == b.gid and a.mode == b.mode
  end
end
