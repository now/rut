# -*- coding: utf-8 -*-

class Rut::VFS::Local::Windows::Rut < Rut::VFS::Local::POSIX::Rut
  class << self
    def separators
      '/\\\\'
    end

    def split_root(path)
      if path =~ %r{\A((?://|\\\\)[^/\\]+[/\\][^/\\]*[/\\]?|[a-z]:[/\\])(.*)}i
        root, path = $1, $2
        [root.gsub('\\', '/'), path]
      else
        super
      end
    end
  end

  def basename
    path =~ /\A[a-z]:[#{self.class.separators}]\Z/ ? '/' : super
    # TODO: I don’t know why we would need this test.
    # return $1 if windows? and path =~ %r{\A[a-z]:.*?([^/\\]+)\z}i
  end

  def replace(options = {})
    output = Rut::Streams::Outputs::File.new(Rut::Streams::Outputs::Files::Local::Windows.replace(self, options))
    return output unless block_given?
    begin yield(output) ensure output.close end
  end
end
