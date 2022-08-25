# frozen_string_literal: true

class ColorPrinter
  NOCOLOR = "\e[0m"

  COLORS = [:black, :red, :green, :brown, :blue, :magenta, :cyan, :gray, :bg_red, :bg_gray].freeze

  COLORS.each do |color|
    define_singleton_method("print_#{color}") do |text|
      print text, color
    end

    define_singleton_method(color) do |text|
      colorize(text, color)
    end
  end

  def self.colorize(text, color)
    "#{color_code(color)}#{text}#{NOCOLOR}"
  end

  def self.print(text, color = nil)
    if color.nil?
      puts text
    else
      puts colorize(text, color)
    end
  end

  def self.with_logger(level = :info)
    raise ArgumentError, "Invalid logger level" unless Rails.logger.respond_to?(level)

    Class.new.tap do |klass|
      klass.define_singleton_method :method_missing do |m, *args|
        super(m, *args) unless m.to_s.slice(0, 5) == 'print' && ColorPrinter.respond_to?(m)

        Rails.logger.public_send(level, args.first)
        ColorPrinter.public_send(m, *args)
      end
    end
  end

  def self.color_code(color)
    case color
    when :black
      "\e[30m"
    when :red
      "\e[31m"
    when :green
      "\e[32m"
    when :brown
      "\e[33m"
    when :blue
      "\e[34m"
    when :magenta
      "\e[35m"
    when :cyan
      "\e[36m"
    when :gray
      "\e[37m"
    when :bg_red
      "\e[41m"
    when :bg_gray
      "\e[47m"
    else
      raise ArgumentError, "invalid color!"
    end
  end

  def self.paper_jam!
    codes = ["\u{1F5A8}", "\u{1F4C4}", "\u{2734}"]
    print Array.new(rand(1_000)).map { codes.sample }.join + "\n"
  end
end
