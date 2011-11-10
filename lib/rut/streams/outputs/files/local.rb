# -*- coding: utf-8 -*-

module Rut::Streams::Outputs::Files::Local
  autoload :POSIX, 'rut/streams/outputs/files/local/posix'
  autoload :Windows, 'rut/streams/outputs/files/local/windows'

  class << self
    def append(rut, flags = Rut::Create::None)
      POSIX.append(rut, flags)
    end

    def replace(rut, options = {})
      (Rut.windows? ? Windows : POSIX).replace(rut, options)
    end
  end
end
