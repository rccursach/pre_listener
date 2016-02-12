require 'redis'

module PRI_FRUTAS
	class Cache

		@db = nil
		@nodetable_name
		@datalist_name

		def initialize host, port, nodetable_name, datalist_name
			db_host = host.nil? ? 'localhost' : host
			db_port = port.nil? ? 6379 : port
			@nodetable_name = nodetable_name.nil? ? 'pri_nodes' : nodetable_name.to_s
			@datalist_name = datalist_name.nil? ? 'pri_data' : datalist_name.to_s
			
			begin
				@db = Redis.new(:host => db_host, :port => db_port)
			rescue Exception => e
				puts e.message
				exit 1
			end

		end

		def update_node str_nodename, str_data
			@db.hset @nodetable_name, str_nodename.to_s, str_data.to_s
		end

		def clear_table
			@db.del @nodetable_name #clear the list of reported nodes
		end

		def insert_data

		end

		def get_cmd_count
			return @db.llen 'pri_cmd'
		end

		def get_cmd
			return @db.rpop 'pri_cmd'
		end
	end
end