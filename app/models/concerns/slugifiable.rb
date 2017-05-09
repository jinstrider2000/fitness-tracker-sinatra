require "cgi"

module Slugifiable

  def create_slug
    CGI.escape(self.name.downcase).gsub("+","-")
  end

end
