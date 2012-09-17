#!/usr/local/bin/ruby
$:.unshift File.dirname($0)
APP_ROOT =  File.expand_path(File.dirname(__FILE__)) unless defined? APP_ROOT

require 'rubygems'
require 'bundler/setup'
Bundler.require

@opts = Trollop::options do    
	text "Local update server:"
	opt :run, "Start update server"
	opt :port, "Start update server", :default => 9090 
	
	text "\nCheck remote update:"	
	opt :sync, "Check last version on remote server"
	opt :remote_url, "Remote server URL", :default => 'http://update.vmp.ru/json', :short => '-u'
	
	text "\nOther:"	
	opt :database, "Database file", :default => File.join(APP_ROOT, 'updates.db'), :short => '-d'
	opt :cache, "Folder for cache", :default => File.join(APP_ROOT), :short => '-c'
	conflicts :run, :sync
	#depends	:run, :remote_url
 end

 OPTS = @opts
 require 'db.rb'
 require 'server.rb' if @opts[:run]
 require 'sync.rb' if @opts[:sync]