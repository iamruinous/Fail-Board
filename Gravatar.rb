# Gravatar.rb
# fail
#
# Created by Matthew Chavez on 6/2/10.
# Copyright 2010 __MyCompanyName__. All rights reserved.

module Gravatar

  def gravatar(email, size = 30)
    gravatar_id = Digest::MD5.hexdigest(email.to_s.strip.downcase)
    gravatar_for_id(gravatar_id, size)
  end

  def gravatar_for_id(gid, size = 30)
    "#{gravatar_host}/avatar/#{gid}?s=#{size}"
  end

  def gravatar_host
    'http://www.gravatar.com'
  end

end
