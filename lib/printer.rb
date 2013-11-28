class Printer

  attr_reader :printer_name
  def initialize(printer_name="thermal_2844")
    @printer_name = printer_name
  end

  def print_item_label(label)
    result = Open3.popen3("lp -d #{printer_name} -o raw"){|i, o| i<<label;i.close;o.read}
    !result.empty?
  end

  def stop
  end
end
