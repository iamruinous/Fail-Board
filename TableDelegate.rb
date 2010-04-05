# TableDelegate.rb
# fail
#
# Created by Matthew Chavez on 4/4/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.


class TableDelegate

  attr_accessor :parent, :project
  
  def numberOfRowsInTableView(tableView)
    parent.failure_count
  end
	
  def tableView(tableView, willDisplayCell:cell, forTableColumn:column, row:row)
	font    = NSFont.fontWithName("Helvetica-Bold", size:20.0)
	project = parent.failures[row]
	
	cell.setStringValue(project[column.identifier.to_sym])
	cell.setTextColor(NSColor.whiteColor)
	cell.setFont(font)
	return cell
  end
end