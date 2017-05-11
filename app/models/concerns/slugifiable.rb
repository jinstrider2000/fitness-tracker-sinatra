require "cgi"

module Slugifiable

  def create_slug
    self.update(slug: "#{self.id}-#{CGI.escape(self.name.downcase).gsub("+","-")}")
  end

end
