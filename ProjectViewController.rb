# ProjectViewController.rb
# fail
#
# Created by Matthew Chavez on 5/22/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class ProjectViewController < NSViewController
	
	attr_accessor :poller, :index, :project, :main_view
	attr_accessor :projectName, :projectCommitter, :projectStatus, :projectDate, :totalPassing, :totalFailing, :gravatar

	def init
		if super
			@index = 0
			@poller = ProjectPoller.sharedPoller
			@timer = nil
			puts @index
			puts @poller.inspect
			NSNotificationCenter.defaultCenter.addObserver(self, selector:(:start_display), name:"ProjectsPulled", object:nil)
			self
		end
	end
	
	def start_display
		@timer.invalidate if @timer
		@timer = NSTimer.scheduledTimerWithTimeInterval(10.0, target:self, selector:(:loadProject), userInfo:nil, repeats:true)
	end
	
	def awakeFromNib
		main_view.addSubview(view)
		view.window.setBackgroundColor backgroundColor
	end
	
	def nibName
		"ProjectViewController"
	end
	
	def backgroundColor
		NSColor.colorWithCalibratedRed(0.498, green:0.0, blue:0.00, alpha:1.0)
	end
	
	def passingBackground
		NSColor.colorWithCalibratedRed(0.439, green:0.733, blue:0.286, alpha:1.0)
	end
	
	def failingBackground
		backgroundColor
	end
	
	def enterFullScreen(sender)
		if view.isInFullScreenMode()
			view.exitFullScreenModeWithOptions(nil)
		else
			view.enterFullScreenMode(NSScreen.mainScreen, withOptions:nil)
		end
		
		if @project.passing?
			view.window.setBackgroundColor passingBackground
		else
			view.window.setBackgroundColor failingBackground
		end
	end
	
	def loadProject
		puts "Total Projects: #{@poller.projects.count}"
		projects = @poller.failures
		
		@project = Project.new(projects[index])

		puts @project.inspect
		
		projectName.setStringValue(@project.name)
		projectCommitter.setStringValue(@project.committer)
		projectStatus.setStringValue(@project.status)
		projectDate.setStringValue(@project.date)
		totalPassing.setStringValue("#{@poller.passing_count} Pass")
		totalFailing.setStringValue("#{@poller.failure_count} Fail")
		gravatar.setImage(@project.gravatar)
		
		if @project.passing?
			view.window.setBackgroundColor passingBackground
		else
			view.window.setBackgroundColor failingBackground
		end
		
		view.setNeedsDisplay(true)
		
		if @index == projects.count - 1
			@index = 0
		else
			@index += 1
		end
	end
end