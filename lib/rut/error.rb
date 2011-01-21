# -*- coding: utf-8 -*-

class Rut::Error < StandardError
  class << self
    def from(error, message = '%s')
      case error
      when SystemCallError
        (mappings[error.class] or self).new(message % error.message.sub(/ - .*/, ''))
      when IOError
        self.new(error.message)
      else
        error
      end
    end

  private

    def system(*constants)
      constants.each do |constant|
        error = begin
                  Errno.const_get(constant)
                rescue TypeError, NameError
                  nil
                end or next
        mappings[error] = self
      end
    end

    def mappings
      @@mappings ||= {}
    end
  end

  ::Rut::ClosedError = Class.new(self)
  ::Rut::PendingError = Class.new(self)
end

module Rut::Error::Path
  def initialize(message, path = nil)
    super path ? '%s: %s' % [path, message] : message
    @path = path
  end

  attr_reader :path
end

class Rut::ExistsError < Rut::Error
  include Rut::Error::Path

  system :EEXIST
end

class Rut::IsDirectoryError < Rut::Error
  include Rut::Error::Path

  system :EISDIR
end

class Rut::PermissionDeniedError < Rut::Error
  include Rut::Error::Path

  system :EACCES, :EPERM
end

class Rut::NameTooLongError < Rut::Error
  include Rut::Error::Path

  system :ENAMETOOLONG
end

class Rut::NotFoundError < Rut::Error
  include Rut::Error::Path

  system :ENOENT
end

class Rut::NotADirectoryError < Rut::Error
  include Rut::Error::Path

  system :ENOTDIR
end

class Rut::ReadOnlyError < Rut::Error
  include Rut::Error::Path

  system :EROFS
end

class Rut::TooManyLinksError < Rut::Error
  include Rut::Error::Path

  system :ELOOP
end

class Rut::NoSpaceError < Rut::Error
  system :ENOSPC, Errno::ENOMEM
end

class Rut::ArgumentError < Rut::Error
  system :EINVAL
end

class Rut::CanceledError < Rut::Error
  system :ECANCELED
end

class Rut::NotEmptyError < Rut::Error
  include Rut::Error::Path

  system :ENOTEMPTY unless Errno.const_get(:ENOTEMPTY) == Errno.const_get(:EEXIST)
end

class Rut::NotSupportedError < Rut::Error
  include Rut::Error::Path

  system :ENOTSUP
end

class Rut::TimedOutError < Rut::Error
  include Rut::Error::Path

  system :ETIMEDOUT
end

class Rut::BusyError < Rut::Error
  include Rut::Error::Path

  system :EBUSY
end

class Rut::WouldBlockError < Rut::Error
  include Rut::Error::Path

  system :EAGAIN, Errno::EWOULDBLOCK
end

class Rut::TooManyOpenFilesError < Rut::Error
  include Rut::Error::Path

  system :EMFILE
end

class Rut::InvalidNameError < Rut::Error
  include Rut::Error::Path
end
