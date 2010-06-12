# Project.rb
# fail
#
# Created by Matthew Chavez on 5/22/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class Project
	attr_accessor :name, :committer, :date, :status, :email, :gravatar
	
	def initialize(proj = {})
		@name		||= proj[:project]
		@committer	||= proj[:committer]
		@date		||= proj[:date]
		@status		||= proj[:status]
		@email		||= proj[:email]
		@gravatar   ||= proj[:gravatar]
	end
	
	def failing?
		status.downcase == "failed"
	end
	
	def passing?
		status.downcase == "success"
	end
end