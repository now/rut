# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::POSIX::Existing::Temporary::Open
  def initialize(rut, readable, flags)
    @readable, @flags = readable, flags
    offset = rut.path.rindex(Pattern) or
      raise ArgumentError, 'template does not contain %s: %s' % [Pattern, rut.path]
    @before = path[0...offset]
    @after = path[offset+Pattern.length..-1]
  end

  def call
    value = next_value
    Tries.times do
      result = try(value) and return result
      value += 7777
    end
    raise Errno::EEXIST
  end

private

  Letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.freeze
  Pattern = 'XXXXXX'.freeze
  Tries = 100

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
                  IO::CREAT | IO::EXCL | (@readable ? IO::RDWR : IO::WRONLY),
                  @flags & Rut::Create::Private ? 0600 : 0666),
     Rut.new_for_path(path)]
  rescue Errno::EEXIST
    nil
  end
end
