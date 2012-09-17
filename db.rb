class Update
	def self.open opts
		init_table = !File::exists?( opts[:database] )
		@db = ::SQLite3::Database.new( opts[:database] )
		@db.execute2("pragma encoding='utf8'")
		begin
			@db.execute2("CREATE TABLE [updates] ( [id] INTEGER PRIMARY KEY AUTOINCREMENT, [guid] CHAR, [file] CHAR, [date] TIMESTAMP, [version] BIGINT);")
		end if init_table				
		
		@db
	end
	
	def self.get_updates items
		
		@stmt = {}
				
		items.map do |item|
			@stmt[:get_update] = @db.prepare( "select * from updates where version > ? and guid = ? limit 0, 1;")
			@stmt[:chck_guid] = @db.prepare( "select id from updates where guid = ? limit 0, 1;")
			@stmt[:add_guid] = @db.prepare( "insert into updates (guid, [date]) VALUES (?, DATE('0000-01-01'));")
			
			item[:id].downcase!
			result = nil
			@stmt[:chck_guid].bind_params(item[:id])
			res = @stmt[:chck_guid].execute			
			if res.count == 0
				@stmt[:add_guid].bind_params(item[:id])
				@stmt[:add_guid].execute
				p "#{item[:id]} added"
			else		
				@stmt[:get_update].bind_params item[:ver].to_i, item[:id]
				@stmt[:get_update].execute! do |row|result
					begin
						result = {description: '', icon: '', name: ''}						
						result[:id] = row[0] 
						result[:object] = row[1] 
						result[:file] = row[2] 
						result[:date] = row[3]
						result[:version] = row[4] 
					end if row.count > 0
				end
			end		
			result
		end	
	end
	
	def self.get_file id
		res = nil
		@stmt = {}
		@stmt[:get] = @db.prepare( "select file from updates where id = ?;")
		@stmt[:get].bind_params(id.to_i)
		@stmt[:get].execute! do |row|
			res = row[0]
		end
		res
	end
	
	def self.set_updates items	
		@stmt = {}
		@stmt[:update] = @db.prepare( "update updates set file = ?,  date = ?, version = ? where guid = ?;")
		
		items.map do |item|
			@stmt[:update].bind_params item[:file], item[:date], item[:version], item[:object].downcase
			@stmt[:update].execute
		end
	end	
	
	def self.objects
		objects = []
		@db.execute("Select distinct * from updates") do |row|
			begin
				objects << { :id => row[1], :ver => 0, :date => row[3] }
			end if row.count > 0
		end
		objects
	end
end

Update.open @opts