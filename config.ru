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

HARDWARE = {:scale => Scale.new, :printer => Printer.new}

HardwareIO.set :scale, HARDWARE[:scale]
HardwareIO.set :printer, HARDWARE[:printer]

run HardwareIO.new

[:INT, :TERM].each do |signal|
  old_handler = trap(signal) do
    begin
      HARDWARE.values.each(&:stop)
    rescue Exception => e
      puts e
    end
    old_handler.call if old_handler.respond_to?(:call)
  end
end

