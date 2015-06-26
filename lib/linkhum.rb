# encoding: utf-8
require 'addressable/uri'

class LinkHum
  class << self
    NOOP = ->(*){}
    
    def urlify(text, options = {}, &block)
      new(text).urlify(options.merge(link_processor: block))
    end

    def special(pattern = nil, &block)
      return @special unless pattern

      @special and
        puts("Warning: redefining #{self}.special from #{caller.first}")

      @special = [pattern, block]
    end
  end

  PROTOCOLS = '(?:https?|ftp)'
  SPLIT_PATTERN = %r{(#{PROTOCOLS}://\p{^Space}+)}i

  MAX_DISPLAY_LENGHT = 64

  def initialize(text)
    @text = text
    @components = @text.split(SPLIT_PATTERN)
  end

  def urlify(options = {})
    @components.map{|str|
      SPLIT_PATTERN =~ str ? process_url(str, options) : process_text(str)
    }.join
  end

  private

  def process_url(str, options)
    url, punct = str.scan(%r{\A(#{PROTOCOLS}://.+?)(\p{Punct}*)\Z}i).flatten
    return str unless url

    if punct[0] == '/' || (punct[0] == ')' && url.include?('('))
      url << punct.slice!(0)
    end
    
    make_link(url, options) + punct
  end

  def process_text(str)
    pattern, block = self.class.special

    if pattern
      str.gsub(pattern){|s|
        if (u = block.call(*arguments(pattern, s)))
          "<a href='#{u}'>#{s}</a>"
        else
          s
        end
      }
    else
      str
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

    display_length = options.fetch(:max_length, MAX_DISPLAY_LENGHT)
    "<a href='#{canonical}'#{make_attrs(uri, options)}>"\
      "#{truncate(url, display_length)}</a>"
  end

  def make_attrs(uri, options)
    block = options[:link_processor] || method(:link_attrs)
    attrs = block.call(uri) || {}
    return '' if attrs.empty?
    ' ' + attrs.map{|n, v| "#{n}='#{v}'"}.join(' ')
  end

  def link_attrs(*)
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
