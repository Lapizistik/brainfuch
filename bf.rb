#!/usr/bin/env ruby

require 'io/console'

module Brainfuck
  class Mem
    # We want to simulate infinite linear memory in both directions
    def initialize
      @right = [] # this will include 0
      @left = []
      @ptr = 0
    end
    def value
      if @ptr < 0
        @left[-@ptr]
      else
        @right[@ptr]
      end || 0
    end
    def value=(m)
      if @ptr < 0
        @left[-@ptr] = m
      else
        @right[@ptr] = m
      end
    end
    def pinc
      @ptr += 1
    end
    def pdec
      @ptr -= 1
    end
    def zero?
      value == 0
    end
  end
  
  class Interpreter
    def initialize(program)
      @program = program
      @jumps = parse_jumpmarks
    end
    def run
      @mem = Mem.new
      pc = 0
      while pc < @program.length do
        case @program[pc]
        when '>'
          @mem.pinc
        when '<'
          @mem.pdec
        when '+'
          @mem.value += 1
        when '-'
          @mem.value -= 1
        when '.'
          print @mem.value.chr(STDIN.external_encoding || Encoding::UTF_8)
        when ','
          @mem.value = STDIN.noecho(&:getch).ord
        when '['
          pc = @jumps[pc] if @mem.zero?
        when ']'
          pc = @jumps[pc] unless @mem.zero?
        end
        pc += 1
      end
      puts
    end

    def parse_jumpmarks
      jumps = {}
      stack = []
      @program.each_char.with_index do |c,i|
        case c
        when '['
          stack << i
        when ']'
          stack.empty? and raise 'found ] without ['
          j = stack.pop
          jumps[j] = i
          jumps[i] = j
        end
      end
      stack.empty? or raise 'found [ without ]'
      jumps
    end
  end

  class << self
    def run(code)
      Interpreter.new(code).run
    end
    def load(filename)
      Interpreter.new(File.read(filename))
    end
  end
end

# are we run as executable directly?
if __FILE__==$0
  # ok, let's read the program from the command line or STDIN
  # Please note that reading the program from STDIN will interfere
  # with user input
  Brainfuck.run(ARGF.read)
end
