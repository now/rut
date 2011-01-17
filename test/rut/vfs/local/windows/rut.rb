# -*- coding: utf-8 -*-

Expectations do
  expect '/a/b' do Rut::VFS::Local::Windows::Rut.new_for_path('\\a\\b').path end
  expect '//a/b' do Rut::VFS::Local::Windows::Rut.new_for_path('//a/b').path end

  expect nil do Rut::VFS::Local::Windows::Rut.new_for_path('\\').parent end
  expect Rut::VFS::Local::Windows::Rut.new_for_path('/a') do Rut::VFS::Local::Windows::Rut.new_for_path('\\a\\b').parent end
  expect Rut::VFS::Local::Windows::Rut.new_for_path('c:/a') do Rut::VFS::Local::Windows::Rut.new_for_path('c:\\a\\b').parent end
  expect nil do Rut::VFS::Local::Windows::Rut.new_for_path('//a/b').parent end
  expect Rut::VFS::Local::Windows::Rut.new_for_path('//a/b/') do Rut::VFS::Local::Windows::Rut.new_for_path('//a/b/c').parent end
end
