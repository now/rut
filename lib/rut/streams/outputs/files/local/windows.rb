# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::Windows <
      Rut::Streams::Outputs::Files::Local::POSIX
  File = Rut::Streams::Outputs::Files::Local::POSIX::File
  require_relative 'windows/existing.rb'

  class << self
    def replace(rut, options = {})
      new(File.create(rut, options))
    rescue Rut::ExistsError
      new(Existing.replace(rut, options))
    end
  end
end
