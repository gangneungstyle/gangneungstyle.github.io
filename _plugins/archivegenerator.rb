# Jekyll plugin for generating monthly archives for posts
#
# Usage: place this file in the _plugins directory and set the required configuration
#        attributes in the _config.yml file
#

module Jekyll
  class ArchivePage < Page
    include Convertible

    attr_accessor :site, :pager, :name, :ext, :basename, :dir, :data, :content, :output

    # Initialize new ArchivePage
    # +site+ is the Site
    # +month+ is the month
    # +posts+ is the list of posts for the month
    #
    # Returns <ArchivePage>
    def initialize(site, month, posts)
      @site = site
      @month = month
      self.ext = '.html'
      self.basename = 'index'
      self.content = <<-EOS
<ul>
{% for post in page.posts %}
<li><a href="{{ post.url }}">{{ post.title }}</a></li>
{% endfor %}
</ul>
EOS
      self.data = {
        'layout' => 'default',
        'type' => 'archive',
        'title' => "Archive for #{month}",
         'posts' => posts
      }
    end

    # Add any necessary layouts
    # +layouts+ is a Hash of {"name" => "layout"}
    # +site_payload+ is the site payload hash
    #
    # Returns nothing
    def render(layouts, site_payload)
      payload = {
        "page" => self.to_liquid,
        "paginator" => pager.to_liquid
        }.deep_merge(site_payload)
        do_layout(payload, layouts)
    end

    def url
      File.join("/", @month, "index.html")
    end

    def to_liquid
      self.data.deep_merge({
        "url" => self.url,
        "content" => self.content
      })
    end

        # Write the generated page file to the destination directory.
    # +dest_prefix+ is the String path to the destination dir
    # +dest_suffix+ is a suffix path to the destination dir
    #
    # Returns nothing
    def write(dest_prefix, dest_suffix = nil)
      dest = dest_prefix
      dest = File.join(dest, dest_suffix) if dest_suffix
      FileUtils.mkdir_p(dest)
      # The url needs to be unescaped in order to preserve the
      # correct filename
      path = File.join(dest, CGI.unescape(self.url))
      FileUtils.mkdir_p(File.dirname(path))
      File.open(path, 'w') do |f|
        f.write(self.output)
      end
    end

    def html?
      true
    end
  end



  class ArchiveGenerator < Generator
    priority :low
    safe true
 
    # Generates archive pages for each month when a post has been published
    #
    # site - the site
    #
    # Returns nothing
    def generate(site)
      collate_by_month(site.posts).each do |month, posts|
        site.pages << Jekyll::ArchivePage.new(site, month, posts)
      end
    end

    private

    # Generate a list of all month when a post was published. for each months, 
    # generate a list of posts published this month
    #
    # posts - the posts on which the collation is made
    #
    # Return the list of list producec
    def collate_by_month(posts)
      collated = {}
      posts.each do |post|
        key = "%04d/%02d" % [post.date.year, post.date.month]
        if collated.has_key? key
          collated[key] << post
        else
          collated[key] = [post]
        end
      end
      collated
    end
  end
end
