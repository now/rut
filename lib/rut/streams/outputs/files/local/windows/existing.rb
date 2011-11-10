# -*- coding: utf-8 -*-

class Rut::Streams::Outputs::Files::Local::Windows::Existing <
    Rut::Streams::Outputs::Files::Local::POSIX::Existing
  def close
    begin
      sync
    rescue
      try_close
      raise
    end
    @file.close.tap{ @close.call }
  end
end
