# encoding: utf-8

root = ::File.dirname(__FILE__)
require 'thin'
require 'cgi'
require 'rubygems'
require 'bundler'
Bundler.require
require ::File.join( root, 'lib', 'scale' )
require ::File.join( root, 'lib', 'printer' )
require ::File.join( root, 'hardware_io' )

scale_io = Scale.detect
unless scale_io.to_s.empty?
  Scale.set_permissions_if_needed(scale_io)
end

HARDWARE = {
  :scale => Scale.new(scale_io), # Could specify scale path as parameter
  :printer => Printer.new("thermal_2844") #Could specify printer name as parameter
}

HardwareIO.set :scale, HARDWARE[:scale]
HardwareIO.set :printer, HARDWARE[:printer]

run HardwareIO.new

[:INT, :TERM].each do |signal|
  old_handler = trap(signal) do
    begin
      HARDWARE.values.compact.each(&:stop)
    rescue Exception => e
      puts e
    end
    old_handler.call if old_handler.respond_to?(:call)
  end
end

