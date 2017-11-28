class ColorPrinter
  NOCOLOR = "\e[0m"

  COLORS = [:black, :red, :green, :brown, :blue, :magenta, :cyan, :gray, :bg_red, :bg_gray]

  COLORS.each do |color|
    define_singleton_method("print_#{color}") do |text|
      puts colorize(text, color)
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
end

# ADD THESE TOO?
# def bold;           "\e[1m#{self}\e[22m" end
# def italic;         "\e[3m#{self}\e[23m" end
# def underline;      "\e[4m#{self}\e[24m" end
# def blink;          "\e[5m#{self}\e[25m" end
# def reverse_color;  "\e[7m#{self}\e[27m" end
