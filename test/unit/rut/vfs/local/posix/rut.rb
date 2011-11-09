# -*- coding: utf-8 -*-

Expectations do
  expect '/' do Rut::VFS::Local::POSIX::Rut.new_for_path('/./').path end
  expect '//' do Rut::VFS::Local::POSIX::Rut.new_for_path('//').path end
  expect '//' do Rut::VFS::Local::POSIX::Rut.new_for_path('//./').path end
  expect '/' do Rut::VFS::Local::POSIX::Rut.new_for_path('/.//').path end
  expect '/' do Rut::VFS::Local::POSIX::Rut.new_for_path('/././').path end
  expect '/a' do Rut::VFS::Local::POSIX::Rut.new_for_path('/a/d/../').path end
  expect '/' do Rut::VFS::Local::POSIX::Rut.new_for_path('/a/../').path end
  expect '/a/...' do Rut::VFS::Local::POSIX::Rut.new_for_path('/a/.../').path end
  expect '//a/b' do Rut::VFS::Local::POSIX::Rut.new_for_path('//a/b').path end
  expect '/a/b' do Rut::VFS::Local::POSIX::Rut.new_for_path('///a/b').path end
  expect '/a/b' do Rut::VFS::Local::POSIX::Rut.new_for_path('////a/b').path end
  expect '/a/b' do Rut::VFS::Local::POSIX::Rut.new_for_path('/a/./b').path end
  expect '/a/b' do Rut::VFS::Local::POSIX::Rut.new_for_path('/a//b').path end
  expect '/a/b' do Rut::VFS::Local::POSIX::Rut.new_for_path('/a///b///').path end

  expect '/' do Rut::VFS::Local::POSIX::Rut.new_for_path('//').basename end
  expect 'a' do Rut::VFS::Local::POSIX::Rut.new_for_path('/a').basename end
  expect 'b' do Rut::VFS::Local::POSIX::Rut.new_for_path('/a/b').basename end

  expect nil do Rut::VFS::Local::POSIX::Rut.new_for_path('/').parent end
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/a') do Rut::VFS::Local::POSIX::Rut.new_for_path('/a/b').parent end

  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/b') do
    Rut::VFS::Local::POSIX::Rut.new_for_path('/a').child('/b')
  end
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/') do
    Rut::VFS::Local::POSIX::Rut.new_for_path('/').child('/a').parent
  end
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/a') do
    Rut::VFS::Local::POSIX::Rut.new_for_path('/a').parent.child('a')
  end

  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/a/b').to.be.prefixed_by?(Rut::VFS::Local::POSIX::Rut.new_for_path('/a'))
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/a/b').to.be.prefixed_by?(Rut::VFS::Local::POSIX::Rut.new_for_path('/a/'))
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/a/b').not.to.be.prefixed_by?(Rut::VFS::Local::POSIX::Rut.new_for_path('/b'))
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/abc').not.to.be.prefixed_by?(Rut::VFS::Local::POSIX::Rut.new_for_path('/ab'))

  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/').not.to.has_parent?
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/a').to.has_parent?
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/a/b').not.to.has_parent?(Rut::VFS::Local::POSIX::Rut.new_for_path('/b'))
  expect Rut::VFS::Local::POSIX::Rut.new_for_path('/a/b').not.to.has_parent?(Rut::VFS::Local::POSIX::Rut.new_for_path('/a/b'))
end
