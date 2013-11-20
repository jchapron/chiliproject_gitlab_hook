class ReferenceExtractor

  REFERENCE_PATTERN = %r{
    (?<prefix>\W)?                         # Prefix
    (                                      # Reference
       @(?<user>[a-zA-Z][a-zA-Z0-9_\-\.]*) # User name
      |\#(?<issue>([a-zA-Z]+-)?\d+)        # Issue ID
      |!(?<merge_request>\d+)              # MR ID
      |\$(?<snippet>\d+)                   # Snippet ID
      |(?<commit>[\h]{6,40})               # Commit ID
      |(?<skip>gfm-extraction-[\h]{6,40})  # Skip gfm extractions. Otherwise will be parsed as commit
    )
    (?<suffix>\W)?                         # Suffix
  }x.freeze

  TYPES = [:user, :issue, :merge_request, :snippet, :commit].freeze

  attr_accessor :users, :issues, :merge_requests, :snippets, :commits

  def initialize
    @users, @issues, @merge_requests, @snippets, @commits = [], [], [], [], []
  end

  def analyze string
    parse_references(string.dup)
  end

  def parse_references text
    # parse reference links
    text.gsub!(REFERENCE_PATTERN) do |match|
      prefix     = $~[:prefix]
      suffix     = $~[:suffix]
      type       = TYPES.select{|t| !$~[t].nil?}.first

      if type
        identifier = $~[type]

        # Avoid HTML entities
        if prefix && suffix && prefix[0] == '&' && suffix[-1] == ';'
          match
        elsif ref_link = reference_link(type, identifier)
          "#{prefix}#{ref_link}#{suffix}"
        else
          match
        end
      else
        match
      end
    end
  end
  
  def related_issues
    issues.map do |identifier|
      Issue.find(identifier)
    end.reject(&:nil?)
  end

  private

  def reference_link type, identifier
    # Append identifier to the appropriate collection.
    send("#{type}s") << identifier
  end
end