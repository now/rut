# -*- coding: utf-8 -*-

Expectations do
  expect 0 do Rut::Copy::None end
  expect 1 do Rut::Copy::Overwrite end
  expect 2 do Rut::Copy::Backup end
  expect 4 do Rut::Copy::DoNotFollowSymlinks end
  expect 8 do Rut::Copy::AllMetadata end
end
