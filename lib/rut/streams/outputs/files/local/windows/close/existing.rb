# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::Windows::Close::Existing <
      Rut::Streams::Outputs::Files::Local::POSIX::Close::Existing
  def call
    sync
    Rut::Streams::Outputs::Files::Local::POSIX::Close::Simple.new(@io).call
    move_temporary_in_place
  end
end
