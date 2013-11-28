class Scale < SerialPort

  def Scale.new(device_path="/dev/tty.usbserial")
    begin
      super(device_path, 9600) if device_path
    rescue Errno::ENOENT => e
      $stderr.puts "Scale is not setup"
      $stderr.puts e
      $stderr.puts e.backtrace
      nil
    end
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

  # Determines scale server interface
  # @return [String,NilClass]
  def self.detect
    device = Dir.entries("/dev").find{|f| f =~ /tty.*usb.*/i}
    "/dev/#{device}" if device
  end

  # TTY USB character device must ONLY have read/write permissions set:
  # @param [String] device_path
  def self.set_permissions_if_needed( device_path )
    target_permission = 0b110110110
    significant_permissions = File.stat(device_path).mode & target_permission
    # If wrong permissions, set correct permission
    if significant_permissions != target_permission
      puts "Configuring permissions for device: '#{device_path}'"
      linux_permissions = "%o" % target_permission
      `sudo chmod #{ linux_permissions } #{ device_path }`
    end
  end
end

