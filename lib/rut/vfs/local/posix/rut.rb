# -*- coding: utf-8 -*-

class Rut::VFS::Local::POSIX::Rut
  include Rut::VFS::Rut

  class << self
    def new_for_path(path)
      new(path)
    end

    def canonicalize(path)
      root, rest = split_root(absolute?(path) ? path : build(current_dir, path))
      root +
        ((root == '/' and rest =~ /\A[#{separators}](?:[^#{separators}]|\z)/) ? '/' : '') +
        rest.
          gsub(/(?:\G|[#{separators}])(?:\.|[^#{separators}]+[#{separators}]\.\.)([#{separators}]+|\z)/, '\\1').
          gsub(/[#{separators}]+/, '/').
          sub(/\A[#{separators}]/, '').
          sub(/[#{separators}]\z/, '')
    end

    def separators
      '/'
    end

    def split_root(path)
      path =~ /\A([#{separators}])(.*)/ ? ['/', $2] : [nil, path]
    end

    def absolute?(path)
      split_root(path)[0]
    end

    def build(*parts)
      parts.reject{ |part| part.empty? }.reduce(''){ |result, part|
        trimmed = strip_leading_separators(strip_trailing_separators(part))
        if trimmed.empty?
          result << part if result.empty?
        else
          result << '/' unless result.empty? or separator? result[-1].chr
          result << trimmed
        end
      }
    end

    def separator?(string)
      string =~ /\A[#{separators}]\z/
    end

  private

    def strip_leading_separators(path)
      path.sub(/\A[#{separators}]+/, '')
    end

    def strip_trailing_separators(path)
      path.sub(/[#{separators}]+\z/, '')
    end

    def current_dir
      Dir.pwd
    end
  end

  def initialize(path)
    # TODO: Don’t do canonicalization from methods, only for “user input”.
    @path = self.class.canonicalize(path)
  end

  def basename
    path[/\A.*?([^#{self.class.separators}]+)\z/, 1] or '/'
  end

  def parent
    root, rest = self.class.split_root(path)
    return nil if rest.empty?
    self.class.new(rest !~ /[#{self.class.separators}]/ ?
                   root :
                   root + rest.sub(/[#{self.class.separators}][^#{self.class.separators}]+\z/, ''))
  end

  def child(child)
    return self.class.new(child) if self.class.absolute? child
    self.class.new(self.class.build(path, child))
  end
  alias_method :+, :child
  alias_method :/, :child

  def prefixed_by?(prefix)
    path.start_with? prefix.path and
      prefix.path.length < path.length and
      self.class.separator? path[prefix.path.length].chr
  end

  def delete
    begin
      Dir.delete(path)
    rescue Errno::ENOTDIR
      File.delete(path)
    rescue Errno::EEXIST
      raise Errno::ENOTEMPTY
    end
  rescue SystemCallError => e
    raise Rut::Error.from(e)
  end

  def delete_directory
  end

  def info
  end

  def read
    begin
      io = IO.new(IO.sysopen(path, IO::RDONLY | IO::BINARY, 0), IO::RDONLY | IO::BINARY)
    rescue SystemCallError => e
      raise Rut::Error.from(e, 'Error opening file: %s')
    end
    if (io.stat.directory? rescue nil)
      io.close
      raise Rut::IsDirectoryError, 'Cannot open directory'
    end
    input = Rut::Stream::Inputs::Files::Local.new(io)
    return input unless block_given?
    begin
      yield input
    ensure
      input.close
    end
  end

  def mkdir
    Dir.mkdir(path, 0777)
  rescue Errno::EINVAL
    raise Rut::Error::InvalidNameError, 'Invalid filename'
  rescue SystemCallError => e
    raise Rut::Error.from(e)
  end

  def ==(other)
    path == other.path
  end

  def eql?(other)
    self.class === other and self == other
  end

  def hash
    path.hash
  end

  def inspect
    '%s.new_for_path(%p)' % [self.class, path]
  end

  def to_s
    path
  end

  def to_path
    path
  end

  attr_reader :path
end
