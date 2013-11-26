class Printer

  attr_reader :printer_name
  def initialize(printer_name="thermal_2844")
    @printer_name = printer_name
  end

  def print_item_label(label)
    Open3.popen3("lp -d #{printer_name} -o raw") { |stdin, stdout, stderr| stdin << label}
  end

  def stop
  end
end
