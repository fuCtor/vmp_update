require 'net/http'
require 'pathname'

def download_update(uri)
	file_name = Pathname(uri.path).basename.to_s
	cache_path = Pathname(File.join(@opts[:cache], 'cache', uri.path.gsub(file_name, '')))
	
	Net::HTTP.start(uri.host, uri.port) do |http|
		cache_path.mkpath
		f = open(File.join(cache_path, file_name), 'wb')
		puts "Fetch: #{uri.to_s}"
		begin
			http.request_get(uri.path) do |resp|
				resp.read_body do |segment|
					f.write(segment)
				end
			end
		ensure
			f.close()
		end
	end
	File.join(cache_path, file_name)
end

uri = URI(@opts[:remote_url])
Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Post.new uri.request_uri
  objects = Update.objects
  request.body = objects.to_json

  response = http.request(request)
  index = 0
  JSON.parse(response.body, :symbolize_names => true).each do |update|	
	begin
		puts "#{update[:object]} is out of date"
		update[:file] = download_update(URI(update[:file])).encode 'utf-8'
		p update
		Update.set_updates([update]) 
	end if objects[index][:date] < update[:date] if update
	index = index + 1
  end  
end