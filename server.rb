 class Server < E
	map '/'
	
    setup 'json' do
        charset 'UTF-8'
		format :json
    end
	
	def index *args
		send_file File.join(args)
	end	
	
	def post_json
		begin
			req = Rack::Request.new(env)
			items = JSON.parse req.body.read, :symbolize_names => true
			res = Update.get_updates(items).map do |item|
				next unless item
				item[:file] = URI::HTTP.build({:path => item[:file].gsub(OPTS[:cache], ''), :host => req.host, :port => req.port, :scheme => req.scheme})
				item
			end
			res.to_json
		rescue => e
			p e
			print e.backtrace.join("\n")
			[].to_json
		end
	end
end

Server.run  :server => :Thin, :Port => @opts[:port]
