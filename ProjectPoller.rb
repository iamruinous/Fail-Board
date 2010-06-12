# ProjectPoller.rb
# fail
#
# Created by Matthew Chavez on 5/22/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class ProjectPoller

	include Gravatar
	
	BUILDER_BASE_URL = "http://builder.integrumdemo.com"
	PROJECTS_URL     = "#{BUILDER_BASE_URL}/projects"
	PROJECTS_RSS_URL = "#{PROJECTS_URL}.rss"
	
	@@poller = nil
	attr_accessor :projects, :timer
	
	def self.sharedPoller
		if @@poller == nil
			puts 'new poller'
			@@poller = ProjectPoller.new
			@@poller.projects = []
			@@poller.fetch_feed
			@@poller.set_timer
		end

		@@poller
	end
	
	def initialize
		self.projects = []
	end
	
	def set_timer
		self.timer = NSTimer.scheduledTimerWithTimeInterval(180.0, target:self, selector:(:fetch_feed), userInfo:nil, repeats:true)
	end
  
	def refresh_feed(sender)
		NSLog "REFRESH FEED"
		fetch_feed
		self.timer.invalidate()
		set_timer
	end

	def fetch_feed
		NSLog "START PULLING PROJECTS"
		DataRequest.new.get("#{PROJECTS_RSS_URL}"){|data| parse_projects(data)}
	end

	def parse_projects(data)
		doc = NSXMLDocument.alloc.initWithXMLString(data, options:NSXMLDocumentValidate, error:nil)

		unless doc.nil?
			items = doc.rootElement.nodesForXPath('channel/item', error:nil);

			self.projects = items.map do |item|
				title = item.nodesForXPath('title', error:nil).first.stringValue
				title = title.match(/(.*) build/)[1] if title.match(/(.*) build/)
				
				status = item.nodesForXPath('title', error:nil).first.stringValue
				status = status.match(/success/) ? "Success" : "Failed"
				
				committer = item.nodesForXPath('description', error:nil).first.stringValue
				committer = committer.match(/committed by (\w*\s?\w*) (?:on|<|&lt;)/) ? committer.match(/committed by (\w*\s?\w*) (?:on|<|&lt;)/)[1] : 'Integrum User'
				
				date = item.nodesForXPath('pubDate', error:nil).first.stringValue
				date = date.match(/(.*) \d\d:/) ? date.match(/(.*) \d\d:/)[1] : Date.today.strftime("%D, %d %M, %Y")
				
				email = item.nodesForXPath('description', error:nil).first.stringValue
				puts "EMAIL #{email}"
				email = email.match(/<([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})>/) ? email.match(/<([A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4})>/)[1] : ""
				puts "EMAIL MATCH #{email}"
				
				gravatarImage = email.length > 0 ? NSImage.alloc.initWithContentsOfURL(NSURL.URLWithString(gravatar(email, 250))) : NSImage.new
				puts email
				puts gravatarImage
				{
					:project   => "#{title}",
					:status	   => "#{status}", 
					:committer => "#{committer}",
					:date      => "#{date}",
					:email	   => email,
					:gravatar  => gravatarImage
				}
			end

			puts "#{failure_count} PROJECTS FAILING"
			puts "#{passing_count} PROJECTS PASSING"
			NSNotificationCenter.defaultCenter.postNotificationName("ProjectsPulled", object:nil, userInfo:nil)
		else
			NSLog "NO RESULTS FROM BUILDER"
		end
	end

	def has_failures?
		failure_count > 0
	end

	def failures
		projects.select{|project| project.valueForKey(:status).downcase == "failed" }
	end

	def passing
		projects.select{|project| project.valueForKey(:status).downcase == "success" }
	end

	def project_total
		passing_count + failure_count
	end

	def failure_count
		failures.count
	end

	def passing_count
		passing.count
	end
end