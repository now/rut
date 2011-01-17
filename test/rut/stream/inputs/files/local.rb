# -*- coding: utf-8 -*-

require 'stringio'

Expectations do
  expect mock.to.receive.close do |io| Rut::Stream::Inputs::Files::Local.new(io).close end
  expect Rut::Stream::Inputs::Files::Local.new(stub) do |input| input.close end
  expect Rut::Stream::Inputs::Files::Local.new(stub).to.be.closed? do |input| input.close end
  expect Rut::ClosedError do Rut::Stream::Inputs::Files::Local.new(stub).close.with_pending{} end
  expect Rut::PendingError do Rut::Stream::Inputs::Files::Local.new(stub).with_pending{ |input| input.with_pending{} } end
  expect :result do Rut::Stream::Inputs::Files::Local.new(stub).with_pending{ |input| :result } end
  expect true do Rut::Stream::Inputs::Files::Local.new(stub).with_pending{ |input| input.pending? } end

  # TODO: Need a lot more tests for #read
  expect 'abc' do Rut::VFS::Local::Windows::Rut.new_for_path('fixtures/abc').read{ |input| input.read(3) } end
  expect '' do Rut::Stream::Inputs::Files::Local.new(StringIO.new('abc')).tap{ |r| r.read(3) }.read(3) end
  expect Rut::ArgumentError do Rut::Stream::Inputs::Files::Local.new(stub).read(-1) end
end
