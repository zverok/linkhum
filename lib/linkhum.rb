# encoding: utf-8
require 'addressable/uri'

class LinkHum
  class << self
    def urlify(text, options = {}, &block)
      new(text).urlify(options)
    end
  end

  PROTOCOLS = '(?:https?|ftp)'
  SPLIT_PATTERN = /(#{PROTOCOLS}:\/\/\p{^Space}+)/i

  def initialize(text)
    @text = text
    @components = @text.split(SPLIT_PATTERN)
  end

  def urlify(options = {})
    @components.map{|str|
      SPLIT_PATTERN =~ str ? process_url(str, options) : process_text(str)
    }.join
  end

  def process_url(str, options)
    url, punct = str.scan(%r{\A(#{PROTOCOLS}://.+?)(\p{Punct}*)\Z}i).flatten
    return str unless url
    
    url << punct.slice!(0) if (punct[0] == '/' || (punct[0] == ')' && url.include?('(')))
    make_link(url) + punct
  end

  def process_text(str)
    str
  end

  def make_link(url)
    uri = Addressable::URI.parse(url) rescue nil
    return url unless uri

    canonical = Addressable::URI.normalized_encode(uri) rescue uri
    "<a href='#{canonical}'>#{url}</a>"
  end
end
