# -*- coding: utf-8 -*-

class Rut::Streams::Inputs::File
  include Rut::Streams::Input

  def initialize(file)
    super()
    @base = file
  end
end
