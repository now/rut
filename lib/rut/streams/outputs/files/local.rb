# -*- coding: utf-8 -*-

module Rut::Streams::Outputs::Files::Local
  autoload :POSIX, 'rut/streams/outputs/files/local/posix'
  autoload :Windows, 'rut/streams/outputs/files/local/windows'

  class << self
    def append(rut, flags = Rut::Create::None)
      (Rut.windows? ? Windows : POSIX).append(rut, flags)
    end

    def replace(rut, readable = false, etag = nil, backup = false, flags = Rut::Create::None)
      (Rut.windows? ? Windows : POSIX).replace(rut, readable, etag, backup, flags)
    end
  end
end
