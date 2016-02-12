require 'json'
require_relative 'adquisition/serial'
require_relative 'adquisition/cache'

module PRI_FRUTAS
	class Listener
		
		def initialize ser_opt, cache_opt, resp_timeout
			
			@serial = PRI_FRUTAS::SerialAdapter.new ser_opt[:port], ser_opt[:baud]
			@cache = PRI_FRUTAS::Cache.new cache_opt[:host], cache_opt[:port], 'pri_nodes', 'pri_reg'
			
			@serial.set_debug true
			@cache.clear_table

			@resp_timeout = resp_timeout
		end

		def run
			loop do
				c = @serial.get_next_cmd

				if c[:cmd] == 'conectar'
					@serial.send_cmd 'enviar', c[:node_name]
					d = @serial.get_next_data @resp_timeout
					if ! d.nil?
						@serial.send_cmd 'ok', c[:node_name]
						puts d.to_json
						@cache.update_node c[:node_name], d.to_json
					end
				end
				# send the command queue
				while @cache.get_cmd_count > 0 do
					@serial.send_raw_cmd @cache.get_cmd
				end
			end
		end

	end
end

ser_opt = {port: '/dev/ttyUSB0', baud: 57600}
cache_opt = {host: 'localhost', port: 6379}

lstnr = PRI_FRUTAS::Listener.new ser_opt, cache_opt, 62
lstnr.run