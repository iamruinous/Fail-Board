# FailAppDelegate.rb
# fail
#
# Created by Matthew Chavez on 3/20/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class FailAppDelegate
  BUILDER_BASE_URL = "http://builder.integrumdemo.com"
  PROJECTS_URL     = "#{BUILDER_BASE_URL}/projects"
  PROJECTS_RSS_URL = "#{PROJECTS_URL}.rss"
  
  attr_accessor :window, :projects, :status_label, :timer
  attr_accessor :total_fail_label, :total_pass_label, :failed_projects_label
  
  def initialize()
	self.projects = []
  end
  
  def applicationDidFinishLaunching(notification)
	window.setBackgroundColor NSColor.redColor
	
	font = NSFont.fontWithName("Helvetica-Bold", size:40.0)
	status_label.setAllowsEditingTextAttributes(true)
	status_label.setTextColor(NSColor.whiteColor)
	status_label.setFont(font)
	
	font = NSFont.fontWithName("Helvetica-Bold", size:20.0)
	failed_projects_label.setAllowsEditingTextAttributes(true)
	failed_projects_label.setTextColor(NSColor.whiteColor)
	failed_projects_label.setFont(font)
	
	font = NSFont.fontWithName("Helvetica", size:18.0)
	total_pass_label.setAllowsEditingTextAttributes(true)
	total_pass_label.setTextColor(NSColor.whiteColor)
	total_pass_label.setFont(font)
	
	total_fail_label.setAllowsEditingTextAttributes(true)
	total_fail_label.setTextColor(NSColor.whiteColor)
	total_fail_label.setFont(font)
	
	# Set up timer to fetch projects feed
	fetch_feed
	set_timer
  end
  
  def set_timer
	self.timer = NSTimer.scheduledTimerWithTimeInterval(300.0, target:self, selector:(:fetch_feed), userInfo:nil, repeats:true)
  end
  
  def refresh_feed(sender)
    NSLog "REFRESH FEED"
    fetch_feed
	self.timer.invalidate()
	set_timer
  end
  
  def fetch_feed
	NSLog "START PULLING PROJECTS"
	unless DataRequest.new.get("#{PROJECTS_RSS_URL}"){|data| parse_projects(data)}
	  display_builder_fail_message
	end
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
			
			{
				:title     => "#{title}",
				:status	   => "#{status}", 
				:committer => "#{committer}"
			}
		end

		has_failures? ? show_failing : show_passing
	else
		NSLog "NO RESULTS FROM BUILDER"
		display_builder_fail_message
	end
	
	#sleep 30
	#run_updater_loop
  end
  
  def has_failures?
    fail = projects.detect{|project| project.valueForKey(:status) == "Failed" || project.valueForKey(:status) ==  "failed" }
	fail.nil? || fail.count > 0
  end
  
  def failures
	projects.select{|project| project.valueForKey(:status) == "Failed" || project.valueForKey(:status) ==  "failed" }
  end
  
  def passing
	projects.select{|project| project.valueForKey(:status) == "Success" || project.valueForKey(:status) ==  "success" }
  end
  
  def failure_count
	failures.count
  end
  
  def passing_count
	passing.count
  end
  
  def update_failed_projects_label
    self.failed_projects_label.stringValue = ""
	failures.each do |failure|
	  self.failed_projects_label.stringValue += failure.valueForKey(:title) + " - " + failure.valueForKey(:committer) + "\n"
	end
  end
  
  def display_builder_fail_message	
	self.total_pass_label.stringValue = "Pass: -"
	self.total_fail_label.stringValue = "Fail: -"
	self.failed_projects_label.stringValue = "Builder Fail!!! \n\n No Results were returned"
	run_updater_loop
  end
  
  def show_passing
	self.failed_projects_label.stringValue = ""
	window.setBackgroundColor NSColor.greenColor
	self.status_label.stringValue = "Pass"
	update_totals
  end
  
  def show_failing
	window.setBackgroundColor NSColor.redColor
	update_failed_projects_label
	self.status_label.stringValue = "Fail"
	update_totals
  end
  
  def update_totals
    self.total_pass_label.stringValue = "Pass: #{passing_count}"
    self.total_fail_label.stringValue = "Fail: #{failure_count}"
  end

  def dealloc()
	
  end
end