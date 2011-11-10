# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::File
  include Rut::Streams::Output

  def initialize(file)
    super()
    @base = file
  end
end
