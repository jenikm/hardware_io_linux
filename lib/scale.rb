class Scale < SerialPort

  def Scale.new(device_path="/dev/tty.usbserial")
    super(device_path, 9600)
  end

  def read
    weight = nil
    self.read_timeout = 1000
    write "\r\n"
    sleep(0.01)
    (x=readline("\r").to_s.strip).scan(/(\d+\.\d+)(lb|kg)(S)/) do |raw_weight, weight_units, stable|
      weight = raw_weight.to_f
      if weight_units == "kg"
        weight *= pounds_per_kilogram
      end
      weight = weight.round(4)
    end
    weight
  end

  def read_with_retry
    i = 0
    begin
      read
    rescue EOFError => e
      if (i+=1) < max_scale_retries
        retry
      end
    end
  end

  def stop
    $stderr.puts "Stopping Scale..."
    close
  end

  # The conversion rate between pounds and kilograms
  # @return [Float] The number of pounds in a kilogram
  def pounds_per_kilogram
    2.2046
  end

  def max_scale_retries
    5
  end

end