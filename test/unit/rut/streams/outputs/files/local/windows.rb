# -*- coding: utf-8 -*-

Expectations do
  expect 3 do
    Rut::VFS::Local::Windows::Rut.new_for_path('fixtures/out').append{ |output|
      output.write 'abc'
    }
  end

  expect 3 do
    Rut::VFS::Local::Windows::Rut.new_for_path('fixtures/out').replace{ |output|
      output.write 'abc'
    }
  end
end
