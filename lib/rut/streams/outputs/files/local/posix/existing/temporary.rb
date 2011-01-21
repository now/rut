# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Temporary
  class << self
    def try_create(actual, flags, readable)
      return nil unless flags & Rut::Create::ReplaceDestination or (actual.stat.nlink < 2 and not actual.symlink?)
      new(actual.rut, flags, readable, actual.stat).tap{ actual.close }
    rescue Rut::Error
      nil
    end
  end

  def initialize(rut, flags, readable, stat)
    @flags, @readable, @stat = flags, readable, stat
    @io, @rut = Open.new(rut.parent/'.rutoutput-XXXXXX', readable, flags).call
    set_owner_and_permissions flags, stat
  rescue SystemCallError, Rut::Error => e
    begin @io.close rescue SystemCallError end if defined? @io
    @rut.try_delete if defined? @rut
    raise Rut::Error.from(e, 'Error creating temporary file: %s')
  end

  attr_reader :io, :rut

private

  autoload :Open, 'rut/streams/outputs/files/local/posix/existing/actual'

  def set_owner_and_permissions(flags, stat)
    return if flags & Rut::Create::ReplaceDestination
    io.chown stat.uid, stat.gid
    io.chmod stat.mode
  rescue SystemCallError => e
    raise unless already_has_same_owner_and_permissions?(stat)
  end

  def already_has_same_owner_and_permissions?(b)
    a = (io.stat rescue nil) and
      a.uid == b.uid and a.gid == b.gid and a.mode == b.mode
  end
end
