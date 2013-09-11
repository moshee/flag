# encoding: utf-8

# :nodoc:
class Flag
  # :nodoc:
  def initialize(name, kind, default, desc)
    @name, @kind, @default, @desc = name, kind, default, desc
  end

  # :nodoc:
  def convert(val)
    begin
      case @kind
      # bool doesn't have to capture an argument
      # so we don't need a convert case for it
      when :int    then val.to_i
      when :float  then val.to_f
      when :string then val.to_s
      end
    rescue
      raise ArgumentError, "Cannot convert '#{val}' to type #{@kind}"
    end
  end
  attr_reader :name, :kind, :default, :desc
end

class Flags < Hash
  # @abstract Create a new flagset. After parsing, the values can be retrieved
  #   from the flagset using Hash accessor methods using the flag name as the
  #   key.
  # @!attribute [r] args
  #   @return [Array<String>] the argument list passed into initialize
  # @param args [Array<String>] argument list
  # @yield [self] Add flags inside the block if you want. They will be parsed
  #   after the block is executed.
  # @return [self] flagset
  def initialize(args=ARGV)
    @args = args
    @flags = {}

    if block_given?
      yield self
      parse!
    end
  end

  attr_reader :args

  # @abstract Call this if a block was not passed to +initialize+.
  def parse!
    leftover = []
    capturing = nil
    @flags.each_value do |flag|
      self[flag.name] = flag.default
    end
    @args.size.times do |i|
      arg = @args[i]
      if capturing
        self[capturing] = @flags[capturing].convert arg
        capturing = nil
        next
      else
        if arg.size <= 1 or arg[0] != '-'
          leftover << arg
          next
        end
      end
      name = arg[1..-1]
      if flag = @flags[name]
        if flag.kind == :bool
          self[name] = !self[name]
        else
          capturing = name
          next
        end
      end
    end
    @args.replace(leftover)
    raise ArgumentError, "Flag '#{capturing}' requires argument" if capturing
    self
  end

  # @abstract Print the flags and their descriptions and defaults.
  def help(file=$stderr)
    flags = @flags.to_a.sort_by(&:first).map(&:last)
    widest_name = flags.map { |f| f.name.size }.max
    flags.each do |flag|
      file.puts "  -#{flag.name.ljust(widest_name, ' ')}  #{flag.desc} [#{flag.default.inspect}]"
    end
  end

  # @abstract Add a bool flag.
  def bool(name, default, desc)
    check name
    @flags[name] = Flag.new name, :bool, !!default, desc
  end

  # @abstract Add an integer flag.
  def int(name, default, desc)
    check name
    @flags[name] = Flag.new name, :int, default.to_i, desc
  end

  # @abstract Add a floating-point flag.
  def float(name, default, desc)
    check name
    @flags[name] = Flag.new name, :float, default.to_f, desc
  end

  # @abstract Add a string flag.
  def string(name, default, desc)
    check name
    @flags[name] = Flag.new name, :string, default.to_s, desc
  end

  # TODO: this (requires changing @flags from Hash to Array)

  # :nodoc:
  def section(heading)
    # @flags << Flag.new nil, :heading, nil, heading
  end

  private

  def check(name)
    if @flags[name]
      raise RuntimeError, "Flag '#{name}' is being re-defined"
    end
  end
end

