# encoding: utf-8
require 'addressable/uri'
require 'cgi'
require 'strscan'

class LinkHum
  class << self
    NOOP = ->(*){}
    
    def urlify(text, options = {}, &block)
      new(text).urlify(options.merge(link_processor: block))
    end

    def parse(text)
      new(text).parse
    end

    def specials
      @specials ||= []
    end

    def special(pattern, name = nil, &block)
      specials << [pattern, name, block]
    end
  end

  PROTOCOLS = '(?:https?|ftp)'
  URL_PATTERN = %r{(#{PROTOCOLS}://\p{^Space}+)}i

  MAX_DISPLAY_LENGTH = 64

  def initialize(text)
    @text = text
    @components = @text.split(URL_PATTERN)
  end

  def parse
    (@text.split(URL_PATTERN) + ['']).tap{|components|
      (components).each_cons(2){|left, right|
        # ['http://google.com', '/ and stuff'] => ['http://google.com/', ' and stuff']
        shift_punct(left, right) if url?(left) && !url?(right)
      }
    }.reject(&:empty?).
    map{|str|
      url?(str) ? {type: :url, content: str} : parse_specials(str)
    }.flatten
  end

  def urlify(options = {})
    @components.map{|str|
      URL_PATTERN =~ str ? process_url(str, options) : process_text(str)
    }.join
  end

  private

  def url?(str)
    str =~ URL_PATTERN
  end
  
  # NB: nasty inplace strings changing is going on inside, beware!
  def shift_punct(url, text_after)
    url_, punct = url.scan(%r{\A(#{PROTOCOLS}://.+?)(\p{Punct}*)\Z}i).flatten
    return unless url_
    
    if punct[0] == '/' || (punct[0] == ')' && url.include?('('))
      url_ << punct.slice!(0)
    end
    
    url.replace(url_)
    text_after.prepend(punct)
  end

  def parse_specials(str)
    res = []
    str = str.dup
    while !str.empty?
      md = (specials_pattern.match(str)) or break
      md.length.zero? and fail(RuntimeError, "Empty string matched by special at '#{str}'")
      
      res << {type: :text, content: md.pre_match}
      res << {type: :special, content: md[0]}
      str = md.post_match
    end
    res << {type: :text, content: str}
    res.reject{|r| r[:content].empty?}.each{|r|
      update_special(r) if r[:type] == :special
    }
  end

  def specials_pattern
    @specials_pattern ||= Regexp.union(self.class.specials.map(&:first))
  end

  def update_special(hash)
    str = hash[:content]
    pattern, name, _block = self.class.specials.find{|p, n, b| str[p] == str}
    hash.update(name: name, captures: pattern.match(str).captures)
  end

  def process_url(str, options)
    url, punct = str.scan(%r{\A(#{PROTOCOLS}://.+?)(\p{Punct}*)\Z}i).flatten
    return str unless url

    if punct[0] == '/' || (punct[0] == ')' && url.include?('('))
      url << punct.slice!(0)
    end
    
    make_link(url, options) + punct
  end

  def process_text(str)
    str = CGI.escapeHTML(str)
    
    if self.class.specials.empty?
      str
    else
      replace_specials(str)
    end
  end

  def replace_specials(str)
    patterns = self.class.specials.map(&:first)
    blocks = self.class.specials.map(&:last)
    
    str.gsub(Regexp.union(patterns)) do |s|
      pattern = patterns.detect{|p| s[p] == s}
      idx = patterns.index(pattern)
      
      if idx && (u = blocks[idx].call(*arguments(pattern, s)))
        "<a href='#{screen_feet(u)}'>#{s}</a>"
      else
        s
      end
    end
  end

  def arguments(pattern, string)
    m = pattern.match(string)
    m.captures.empty? ? m[0] : m.captures
  end

  def make_link(url, options)
    uri = Addressable::URI.parse(url) rescue nil
    return url unless uri

    canonical = Addressable::URI.normalized_encode(uri) rescue uri

    display_length = options.fetch(:max_length, MAX_DISPLAY_LENGTH)
    "<a href='#{screen_feet(canonical)}'#{make_attrs(uri, options)}>"\
      "#{truncate(CGI.escapeHTML(url), display_length)}</a>"
  end

  def make_attrs(uri, options)
    block = options[:link_processor] || method(:link_attrs)
    attrs = block.call(uri) || {}
    return '' if attrs.empty?
    ' ' + attrs.map{|n, v| "#{n}='#{v}'"}.join(' ')
  end

  def link_attrs(*)
  end

  # TIL that ' (single quote) is in fact "feet mark"
  def screen_feet(url)
    url.gsub("'", '%27')
  end

  # stolen from activesupport/lib/active_support/core_ext/string/filters.rb
  # then simplified
  def truncate(string, truncate_at)
    return string.dup if !truncate_at || string.length <= truncate_at

    omission = '...'
    stop = truncate_at - omission.length

    "#{string[0, stop]}#{omission}"
  end
end
