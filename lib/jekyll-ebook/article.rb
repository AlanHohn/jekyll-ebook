# The Article class loads a file that is formatted as a Jekyll post or 
# page with metadata in a YAML block at the top and the content in 
# Markdown or HTML. It has a method to export the metadata in a format 
# suitable for conversion to EPUB using Pandoc.

class Article

  # +filename+ is the name of the Jekyll post or page
  # +metadata+ is the metadata read in from the post or page
  # +content+ is the body of the post or page
  # +required_fields+ is the list of metadata items to include
  attr_accessor :filename, :metadata, :content, :required_fields

  # Retrieve the filename then call the method to read its data. Pass 
  # required_fields along but delete 'title' since we're going to print 
  # it regardless.
  def initialize( filename, required_fields )
    @required_fields = required_fields.delete_if { |f| f == "title" }
    @filename = filename
    self.read_file
  end

  # Read the metadata and content from the Jekyll post or page
  def read_file

    self.content = File.read(@filename)

    # Define a regular expression to find the YAML header Use the back 
    # reference to load the metadata and the postmatch to load the 
    # content.
    begin
      if /^(---\s*\n.*?\n?)^(---\s*$\n?)/m.match(self.content)
        self.metadata = YAML.load($1)
        self.content = $'
      end
    rescue => e
      puts "YAML exception reading #{filename}: #{e.message}"
    end

  end

  # Print the relevant metadata in a block with CSS selectors for 
  # formatting in the e-book, then print the content
  def format_article

    # an array to hold all our output
    out = Array.new

    out.push "# " + self.metadata['title'] + "\n\n"

    # Loop through the required fields, printing them if they exist
    self.required_fields.each do |f|
      out.push "<p class='#{f}'>" + self.metadata[f] + "</p>\n\n" unless self.metadata[f].nil?
    end

    map = {'{% highlight text %}' => '<pre>', '{% endhighlight %}' => '</pre>'}
    re = Regexp.union(map.keys)
    out.push self.content.gsub(re, map)
    #out.push self.content

    # Return the contents of the array
    return out.join("\n")

  end

end
