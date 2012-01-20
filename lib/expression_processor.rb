require "expression_processor/version"

module ExpressionProcessor
  class BlankSlate
    instance_methods.each {|m| undef_method m unless m =~ /^(__|instance_eval|object_id)/}
  end

  class Expression
    attr_accessor :constants, :errors, :expression

    def initialize(expression)
      @constants  = {}
      @errors     = []
      @expression = expression || ""
    end

    def constants=(constants)
      constants.each {|constant, value| @constants[constant.to_s.downcase.to_sym] = value }
    end

    def eval
      proxy     = Proxy.new(@constants)
      untainted = preprocess.untaint
      result    = valid? ? proc { $SAFE = 3; proxy.instance_eval(untainted) }.call : 0
      result.to_f.round(2)
    end

    def preprocess
      executable = @expression.downcase
      tokenize.each do |token|
        case token[0]
          # ignore dollar signs
          when :dollar
            executable.gsub!(/\$/, '')
          # convert percent to decimal 10% => 0.10
          when :percent
            executable.gsub!(/(#{token[1]})/) {|match| match.gsub(/(%)/, '').to_f / 100 }
        end
      end

      # HACK: make sure operators have surrounding whitespace or calculations dont always
      # have correct result (possibly an eval issue?)
      executable.gsub!(/([%\/*+-])/, " \\1 ")
      executable
    end

    def tokenize
      @tokens ||= Lexer.new(@expression).tokenize
    end

    def valid?(constants = nil)
      validate(constants)
      @errors.empty?
    end

    private
      def validate(constants = nil)
        constants ||= @constants.keys

        # check parentheses count
        @errors << "has mismatched parenthesis" unless @expression.scan(/[()]/).length % 2 == 0

        # check all tokens are valid
        tokenize.each do |token|
          case token[0]
          when :call
            @errors << "calls invalid method #{token[1]}" unless Proxy.instance_methods.include?(token[1].downcase.to_sym)
          when :identifier
            @errors << "uses invalid indentifier #{token[1]}" unless constants.include?(token[1].downcase) || constants.include?(token[1].downcase.to_sym)
          when :operator
          when :float
          when :percent
          when :dollar
          when "("
          when ")"
          when ','
          else
            @errors << "has unrecognized token #{token[0]}"
          end
        end
      end
  end

  class Lexer
    def initialize(code)
      @code = code.upcase.gsub(/\s/, '')
      @tokens = []
    end

    def tokenize
      position  = 0

      # scan one character at a time
      while position < @code.size
        chunk = @code[position..-1]

        if token = chunk[/\A([A-Z]\w*)\(/, 1]
          @tokens << [:call, token]
        elsif token = chunk[/\A([A-Z]\w*)/, 1]
          @tokens << [:identifier, token]
        elsif token = chunk[/\A([0-9.]+%{1})/, 1]
          @tokens << [:percent, token]
        elsif token = chunk[/\A(\$)[\d.]+/, 1]
          @tokens << [:dollar, token]
        elsif token = chunk[/\A([0-9.]+)/, 1]
          @tokens << [:float, token.to_f]
        elsif token = chunk[/\A([%\/*+-])/, 1]
          @tokens << [:operator, token]
        else
          token = chunk[0,1]
          @tokens << [token, token]
        end

        position += token.size
      end

      @tokens
    end
  end

  class Proxy < BlankSlate
    def initialize(constants)
      @constants = constants
    end

    def method_missing(sym, *args, &block)
      @constants[sym] || 0.0
    end

    def max(*values)
      values = values.flatten! || values
      values.max
    end

    def min(*values)
      values = values.flatten! || values
      values.min
    end

    def round(value)
      value.to_f.round
    end

    def sum(*values)
      values = values.flatten! || values
      values.inject(0.0) {|total, value| total += value if value.is_a?(Numeric) }
    end
  end
end

