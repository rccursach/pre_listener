module PRI_FRUTAS
	class Node
		@@states = { normal: 1, reporting: 2, off: 3 }
		@status = nil
		@name = nil
		@report_data = nil
		@last_report = nil

		def initialize name
			@status = @@states[:normal]
			@name = name.to_s
		end

		def report data
			@last_report = Time.now().to_s
			@report_data = data
		end

		def change_reporting
			@status = @@states[:reporting]
		end

		def change_normal
			@status = @@states[:normal]
		end

		def change_off
			@status = @@states[:off]
		end
	end
end