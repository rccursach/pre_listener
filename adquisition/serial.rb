require 'serialport'
#require 'rubyserial'
require_relative 'parser'

module PRI_FRUTAS
	class SerialAdapter
		@cmd_regex = /([a-zA-Z])\w+;([a-zA-Z])\w+/
		@data_regex = /(([A-z0-1])\w+:([0-9])\w+(\.[0-9])?;)+/
		@s = nil
		@p = nil
		@debug = false

		def initialize port, baud
			#Initialize serialport
			port = '/dev/ttyACM0' if port.nil?
      		baud = 9600 if baud.nil?

			begin
				@s = SerialPort.new(port.to_s, baud);
				@s.read_timeout = 1000

				@p = PRI_FRUTAS::Parser.new

			rescue Exception => e
				puts e.message
				#if no serialport exit with error
				exit 1 if @s == nil
			end
		end

		def get_next_data timeout_sec
			data = nil
			ti = Time.now
			tf = ti
			@s.flush_input

			while (tf-ti).to_i < timeout_sec do
				s = gets
				puts "DATA get_next_data: #{s}" if @debug and !s.nil?
				data = @p.decode_data s if s =~ @data_regex
				return data if !data.nil?

				tf = Time.now
				print "."
			end

			return data
		end

		def get_next_cmd
			data = nil
			@s.flush_input
			loop do
				s = gets
				puts "DATA get_next_cmd: #{s}" if @debug and !s.nil?
				data = @p.decode_cmd s if s =~ @cmd_regex
				return data if !data.nil?
				print ","
				sleep 1
			end
		end

		def send_cmd cmd, station
			s = "#{cmd}:#{station}"
			@s.write s if (!cmd.nil?) and (!station.nil?)
			puts "DATA send_cmd: #{s}" if @debug
		end

		def set_debug flag
			@debug = flag === true ? flag : false
		end

		private

		def gets
			return @s.gets.to_s.chomp
		end
	end
end