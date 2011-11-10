# -*- coding: utf-8 -*-

module Rut::Test end

class Rut::Test::Input
  def initialize
    @call = 0
  end

  def sysread(bytes, buffer)
    case @call += 1
    when 0, 2 then raise Errno::EINTR
    when 1 then buffer.replace 'a'
    when 3 then buffer.replace 'bc'
    else buffer.replace ''
    end
  end
end

class Rut::Test::Output
  def initialize
    @call = 0
    @contents = ''
  end

  def syswrite(string)
    case @call += 1
    when 0, 2 then raise Errno::EINTR
    when 1 then @contents << string
    when 3 then return 0
    when 4, 5 then @contents << string[0]
    else raise 'unexpected invocation'
    end
    1
  end

  attr_reader :contents
end

Expectations do
  expect 'abc' do
    output = Rut::Test::Output.new
    Rut::Streams::Outputs::Files::Local::POSIX::Existing::Backup::Copy.new(Rut::Test::Input.new, output).call
    output.contents
  end
end
