
require "cirru/parser/version"
require 'tree'

module Cirru
  module Parser

    def Parser.parse(code, filename)
      buffer = nil

      state = { name: :indent,
        x: 1,
        y: 1,
        level: 1,
        indent: 1,
        indented: 1,
        nest: 0,
        path: filename
      }

      xs = []
      while code.length > 0
        xs, buffer, state, code = *(parse xs, buffer, state, code)
      end
      res = parse xs, buffer, state, code
      res = res.map Tree.resolveDollar
      res = res.map Tree.resolveComma
      res
    end

    def shorten(xs)
      if xs.is_a? Array
        xs.map shorten
      else
        xs.text
      end
    end

    def Parser.pare(code, filename)
      res = Parser.parse code, filename
      shorten res
    end

    # eof

    def escape_eof(xs, buffer, state, code)
      raise 'EOF in escape state'
    end

    def string_eof(xs, buffer, state, code)
      raise 'EOF in string state'
    end

    def space_eof(xs, buffer, state, code)
      xs
    end

    def token_eof(xs, buffer, state, code)
      buffer[:ex] = state[:x]
      buffer[:ey] = state[:y]
      xs = Tree.appendBuffer xs, state[:level], buffer
      buffer = nil
      xs
    end

    def indent_eof(xs, buffer, state, code)
      xs
    end

    # escape

    def escape_newline(xs, buffer, state, code)
      raise 'newline while escape'
    end

    def escape_n(xs, buffer, state, code)
      state[:x] += 1
      buffer[:text] += '\n'
      state[:name] = 'string'
      [xs, buffer, state, code[1..-1]]
    end

    def escape_t(xs, buffer, state, code)
      state[:x] += 1
      buffer[:text] += '\t'
      state[:name] = 'string'
      [xs, buffer, state, code[1..-1]]
    end

    def escape_else(xs, buffer, state, code)
      state[:x] += 1
      buffer[:text] += code[0]
      state[:name] = 'string'
      [xs, buffer, state, code[1..-1]]
    end

    #string

    def string_backslash(xs, buffer, state, code)
      state[:name] = 'escape'
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    def string_newline(xs, buffer, state, code)
      raise 'newline in a string'
    end

    def string_quote(xs, buffer, state, code)
      state[:name] = 'token'
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    def string_else(xs, buffer, state, code)
      state[:x] += 1
      buffer[:text] += code[0]
      [xs, buffer, state, code[1..-1]]
    end

    # space

    def space_space(xs, buffer, state, code)
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    def space_newline(xs, buffer, state, code)
      if state[:nest] != 0
        raise 'incorrect nesting'
      end
      state[:name] = 'indent'
      state[:x] = 1
      state[:y] += 1
      state[:indented] = 0
      [xs, buffer, state, code[1..-1]]
    end

    def space_open(xs, buffer, state, code)
      nesting = tree.createNesting(1)
      xs = tree.appendList xs, state[:level], nesting
      state[:nest] += 1
      state[:level] += 1
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    def space_close(xs, buffer, state, code)
      state[:nest] -= 1
      state[:level] -= 1
      if state[:nest] < 0
        raise 'close at space'
      end
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    def space_quote(xs, buffer, state, code)
      state[:name] = 'string'
      buffer = {text: '',
        x: state[:x],
        y: state[:y],
        path: state[:path]
      }
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    def space_else(xs, buffer, state, code)
      state[:name] = 'token'
      buffer = { text: code[0],
        x: state[:x],
        y: state[:y],
        path: state[:path]
      }
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    # token

    def token_space(xs, buffer, state, code)
      state[:name] = 'space'
      buffer[:ex] = state[:x]
      buffer[:ey] = state[:y]
      xs = tree.appendBuffer xs, state[:level], buffer
      state[:x] += 1
      buffer = nil
      [xs, buffer, state, code[1..-1]]
    end

    def token_newline(xs, buffer, state, code)
      state[:name] = 'indent'
      buffer[:ex] = state[:x]
      buffer[:ey] = state[:y]
      xs = tree.appendBuffer xs, state[:level], buffer
      state[:indented] = 0
      state[:x] = 1
      state[:y] += 1
      buffer = nil
      [xs, buffer, state, code[1..-1]]
    end

    def token_open(xs, buffer, state, code)
      raise 'open parenthesis in token'
    end

    def token_close(xs, buffer, state, code)
      state[:name] = 'space'
      buffer[:ex] = state[:x]
      buffer[:ey] = state[:y]
      xs = tree.appendBuffer xs, state[:level], buffer
      buffer = nil
      [xs, buffer, state, code]
    end

    def token_quote(xs, buffer, state, code)
      state[:name] = 'string'
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    def token_else(xs, buffer, state, code)
      buffer[:text] += code[0]
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    # indent

    def indent_space(xs, buffer, state, code)
      state[:indented] += 1
      state[:x] += 1
      [xs, buffer, state, code[1..-1]]
    end

    def indent_newilne(xs, buffer, state, code)
      state[:x] = 1
      state[:y] += 1
      state[:indented] = 0
      [xs, buffer, state, code[1..-1]]
    end

    def indent_close(xs, buffer, state, code)
      raise 'close parenthesis at indent'
    end

    def indent_else(xs, buffer, state, code)
      state[:name] = 'space'
      if (state[:indented] % 2) == 1
        raise 'odd indentation'
      end
      indented = state[:indented] / 2
      diff = indented - state[:indent]

      if diff <= 0
        nesting = tree.createNesting 1
        xs = tree.appendList xs, (state[:level] + diff - 1), nesting
      else if diff > 0
        nesting = tree.createNesting diff
        xs = tree.appendList xs, state[:level], nesting
      end

      state[:level] += diff
      state[:indent] = indented
      [xs, buffer, state, code]
    end

    # parse

    def parse(*args)
      xs, buffer, state, code = *args
      # scope = {code, xs, buffer, state}
      # window.debugData.push (lodash.cloneDeep scope)
      eof = code.length == 0
      char = code[0]
      case state.name
      when 'escape'
        if eof      then  escape_eof        *args
        else
          case char
          when '\n' then  escape_newline    *args
          when 'n'  then  escape_n          *args
          when 't'  then  escape_t          *args
          else            escape_else       *args
          end
        end
      when 'string'
        if eof      then  string_eof        *args
        else
          case char
          when '\\' then  string_backslash  *args
          when '\n' then  string_newline    *args
          when '"'  then  string_quote      *args
          else            string_else       *args
          end
        end
      when 'space'
        if eof      then  space_eof         *args
        else
          case char
          when ' '  then  space_space       *args
          when '\n' then  space_newline     *args
          when '('  then  space_open        *args
          when ')'  then  space_close       *args
          when '"'  then  space_quote       *args
          else            space_else        *args
          end
        end
      when 'token'
        if eof      then  token_eof         *args
        else
          case char
          when ' '  then  token_space       *args
          when '\n' then  token_newline     *args
          when '('  then  token_open        *args
          when ')'  then  token_close       *args
          when '"'  then  token_quote       *args
          else            token_else        *args
          end
        end
      when 'indent'
        if eof      then  indent_eof        *args
        else
          case char
          when ' '  then  indent_space      *args
          when '\n' then  indent_newilne    *args
          when ')'  then  indent_close      *args
          else            indent_else       *args
          end
        end
      end
    end
  end
end
