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
				if !s.nil? and s != ''
					print "DATA get_next_data: #{s}" if @debug
					data = @p.decode_data s if s =~ /(([A-z0-1])\w+:([0-9])\w+(\.[0-9])?;)+/ #@data_regex
					if !data.nil?
						puts if @debug
						return data
					end
					print " <<-- rejected \n" if @debug
				end
				tf = Time.now
			end
			puts "INFO get_next_data: Timeout! #{(tf-ti).to_i} of #{timeout_sec} secs" if @debug
			return data
		end

		def get_next_cmd
			data = nil
			@s.flush_input
			loop do
				s = gets
				if !s.nil? and s != ''
					puts "DATA get_next_cmd: #{s}" if @debug
					data = @p.decode_cmd s if s =~ /([a-zA-Z])\w+;([a-zA-Z])\w+/ #@cmd_regex
					return data if !data.nil?
				end
				sleep 1
			end
		end

		def send_cmd cmd, station
			s = "#{cmd};#{station}"
			@s.write s if (!cmd.nil?) and (!station.nil?)
			puts "DATA send_cmd: #{s}" if @debug
		end

		def send_raw_cmd cmd
			@s.write cmd.to_s if (!cmd.nil?)
			puts "DATA send_raw_cmd: #{cmd}" if @debug
		end

		def set_debug flag
			@debug = flag === true ? flag : false
		end

		private

		def gets
			str = nil
			begin
				str = @s.gets.to_s.chomp
			rescue Exception => e
				puts "ERROR: Serial#gets: #{e.message}"
			end
		end
	end
end
