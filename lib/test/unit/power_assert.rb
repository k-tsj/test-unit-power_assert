require 'test/unit/power_assert/version'

require 'test/unit'
require 'ripper'
require 'pattern-match'

module Test::Unit
  module PowerAssert
    RetValue = Struct.new(:method_id, :value, :colno)

    TARGET_CALLER_DIFF = {return: 5, c_return: 4}
    TARGET_CALLER_INDEX = {return: 3, c_return: 2}

    def assersion_message(line, methods, values)
      set_colno(line, methods, values)
      vals = values.find_all(&:colno).sort_by(&:colno).reverse
      if vals.empty?
        return
      end
      fmt = (vals[0].colno + 1).times.map {|i| vals.find {|v| v.colno == i } ? "%<#{i}>s" : ' '  }.join + "\n"
      ret = "\n"
      ret << line.chomp + "\n"
      ret << sprintf(fmt, vals.each_with_object({}) {|v, h| h[v.colno.to_s.to_sym] = '|' })
      vals.each do |i|
        ret << sprintf(fmt, vals.each_with_object({}) do |j, h|
                         h[j.colno.to_s.to_sym] = [i.value.inspect, '|', ' '][i.colno <=> j.colno]
                       end)
      end
      ret
    end
    module_function :assersion_message

    def set_colno(line, methods, values)
      values.each do |val|
        idx = methods.index {|(method_name,*)| method_name == val.method_id.to_s }
        if idx
          m = methods.delete_at(idx)
          val.colno = m[1][1]
        else
          ridx = values.rindex {|i| i.method_id == val.method_id and i.colno }
          val.colno = line.index(/\b#{Regexp.escape(val.method_id.to_s)}\b/, ridx ? values[ridx].colno + 1 : 0)
        end
      end
    end
    module_function :set_colno

    def extract_methods(sexp)
      match(sexp) do
        with(_[:program, _[s, *_], *_]) do
          extract_methods(s)
        end
        with(_[:method_add_arg, s0, s1]) do
          s0_methods = extract_methods(s0)
          (s0_methods[0..-2] + extract_methods(s1) + [s0_methods[-1]])
        end
        with(_[:arg_paren, s]) do
          extract_methods(s)
        end
        with(_[:args_add_block, _[s], _]) do
          extract_methods(s)
        end
        with(_[Or(:vcall, :fcall), s]) do
          extract_methods(s)
        end
        with(_[:@ident, method_name, pos]) do
          [[method_name, pos]]
        end
        with(_[:binary, *ss]) do
          ss.flat_map {|i| extract_methods(i) }
        end
        with(_[:call, *ss]) do
          ss.flat_map {|i| extract_methods(i) }
        end
        with(_[:method_add_block, s, _]) do
          extract_methods(s)
        end
        with(_[:string_literal, *_]) do
          []
        end
        with(s & Symbol & Not(:".")) do
          [[s.to_s, [nil, nil]]]
        end
        with(s) do
          []
        end
      end
    end
    module_function :extract_methods

    module Assertions
      def power_assert
        base_caller_lengh = -1
        path = nil
        lineno = nil
        line = nil
        methods = nil
        method_ids = nil
        values = []
        trace = TracePoint.new(:return, :c_return) do |tp|
          next if method_ids and not method_ids.find {|i| i == tp.method_id }
          locs = tp.binding.eval('caller_locations')
          if locs.length - base_caller_lengh == PowerAssert::TARGET_CALLER_DIFF[tp.event]
            idx = PowerAssert::TARGET_CALLER_INDEX[tp.event]
            path ||= locs[idx].path
            lineno ||= locs[idx].lineno
            line ||= open(path).each_line.drop(lineno - 1).first
            methods ||= PowerAssert.extract_methods(Ripper.sexp(line))
            method_ids ||= methods.map(&:first).map(&:to_sym)
            if path == locs[idx].path and lineno == locs[idx].lineno
              values << PowerAssert::RetValue[tp.method_id, tp.return_value, nil]
            end
          end
        end
        prc = -> { PowerAssert.assersion_message(line, methods, values) }
        class << prc
          alias to_s call
        end
        assert_block(prc) do
          trace.enable do
            base_caller_lengh = caller_locations.length
            yield
          end
        end
      end
    end
  end

  class TestCase
    include PowerAssert::Assertions
  end
end
