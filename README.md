# LinkHum

**LinkHum** (aka "Links Humana") is URL auto-linker for user-entered texts.
It tries hard to do the most reasonable thing even in complex cases.

It will be useful for sites with plain-text user input

Features:
* auto-links URL;
* very accurate detection of punctiations inside and outside of URL;
* excessive tests set for complex (yet real-life) texts with URLs;
* customizable behavior.

**NB**: the original algo was written by [squadette](https://github.com/squadette)
and the test cases provided by users of _some secret social network_.
Just gemifying this (on behalf of original author).

## Install

```
[sudo] gem install linkhum
```

Or in your Gemfile

```ruby
gem 'linkhum'
```

And then

```
bundle install
```

## Usage

As simple as:

```ruby
LinkHum.urlify("Please look at http://github.com/zverok/linkhum, it's awesome!")
# => 'Please look at <a href="http://github.com/zverok/linkhum">http://github.com/zverok/linkhum</a>, it's awesome!'
```

## Showcase

```ruby
# Doesn't touch punctuations outside:
LinkHum.urlify('http://slashdot.org, or http://lwn.net? They say, "just http://google.com"')
# => "<a href='http://slashdot.org'>http://slashdot.org</a>, or <a href='http://lwn.net'>http://lwn.net</a>? They say, \"just <a href='http://google.com'>http://google.com</a>\""

# But processes it inside:
LinkHum.urlify('Watch this: https://www.youtube.com/watch?v=Q9Dv4Hmf_O8')
# => "Watch this: <a href='https://www.youtube.com/watch?v=Q9Dv4Hmf_O8'>https://www.youtube.com/watch?v=Q9Dv4Hmf_O8</a>"

# Understands parentheses:
LinkHum.urlify("It's a movie: https://en.wikipedia.org/wiki/Hours_(2013_film) It's just parens: (https://www.youtube.com/watch?v=Q9Dv4Hmf_O8)")
# => "It's a movie: <a href='https://en.wikipedia.org/wiki/Hours_(2013_film)'>https://en.wikipedia.org/wiki/Hours_(2013_film)</a> It's just parens: (<a href='https://www.youtube.com/watch?v=Q9Dv4Hmf_O8'>https://www.youtube.com/watch?v=Q9Dv4Hmf_O8</a>)"

# URL shortening:
LinkHum.urlify("It's too long: http://www.booking.com/searchresults.ru.html?sid=28c7356c8d0fb6d81de3a45eff97e0fe;dcid=4;bb_asr=2&class_interval=1&csflt=%7B%7D&dest_id=-2167973&dest_type=city&group_adults=2&group_children=0&idf=1&label_click=undef&no_rooms=1&offset=0&review_score_group=empty&score_min=0&si=ai%2Cco%2Cci%2Cre%2Cdi&src=index&ss=Lisbon%2C%20Lisbon%20Region%2C%20Portugal&ss_raw=Lisbon&ssb=empty")
# => "It's too long: <a href='http://www.booking.com/searchresults.ru.html?sid=28c7356c8d0fb6d81de3a45eff97e0fe;dcid=4;bb_asr=2&class_interval=1&csflt=%7B%7D&dest_id=-2167973&dest_type=city&group_adults=2&group_children=0&idf=1&label_click=undef&no_rooms=1&offset=0&review_score_group=empty&score_min=0&si=ai,co,ci,re,di&src=index&ss=Lisbon,%20Lisbon%20Region,%20Portugal&ss_raw=Lisbon&ssb=empty'>http://www.booking.com/searchresults.ru.html?sid=28c7356c8d0f...</a>"

# It's customizable:
LinkHum.urlify(
  "It's too long: http://www.booking.com/searchresults.ru.html?sid=28c7356c8d0fb6d81de3a45eff97e0fe;dcid=4;bb_asr=2&class_interval=1&csflt=%7B%7D&dest_id=-2167973&dest_type=city&group_adults=2&group_children=0&idf=1&label_click=undef&no_rooms=1&offset=0&review_score_group=empty&score_min=0&si=ai%2Cco%2Cci%2Cre%2Cdi&src=index&ss=Lisbon%2C%20Lisbon%20Region%2C%20Portugal&ss_raw=Lisbon&ssb=empty",
  max_length: 20)
# =>

# International domains and Non-ASCII paths:
LinkHum.urlify("Domain: http://www.詹姆斯.com/, and path: https://ru.wikipedia.org/wiki/Эффект_Даннинга_—_Крюгера")
# => "Domain: <a href='http://www.詹姆斯.com/'>http://www.詹姆斯.com/</a>, and path: <a href='https://ru.wikipedia.org/wiki/%D0%AD%D1%84%D1%84%D0%B5%D0%BA%D1%82_%D0%94%D0%B0%D0%BD%D0%BD%D0%B8%D0%BD%D0%B3%D0%B0_%E2%80%94_%D0%9A%D1%80%D1%8E%D0%B3%D0%B5%D1%80%D0%B0'>https://ru.wikipedia.org/wiki/Эффект_Даннинга_—_Крюгера</a>"

# Look, ma, no XSS!
LinkHum.urlify('http://example.com/foo?">here.</a><script>window.alert("wow");</script>')
# => "<a href='http://example.com/foo?%22%3Ehere.%3C/a%3E%3Cscript%3Ewindow.alert(%22wow%22);%3C/script%3E'>http://example.com/foo?\">here.</a><script>window.alert(\"wow\")...</a>"
```

## Customization

### On the fly

Custom URL params:

```ruby
LinkHum.urlify("http://oursite.com/posts/12345 has been mentioned at http://cnn.com"){
  |uri|
  uri.host == 'oursite.com' ? {} : {target: '_blank'}
}
# => "<a href='http://oursite.com/posts/12345'>http://oursite.com/posts/12345</a> has been mentioned at <a href='http://cnn.com' target='_blank'>http://cnn.com</a>"
```

Provided block should receive an instance of `Addressable::URI` and
return hash of additional link attributes. You can use it for opening
foreign links in new tab, or for styling them different (Wikipedia-style),
or to provide special icons for links to Youtube, Wikipedia and Google...
Up to you

### Define your own LinkHum

```ruby
class MyLinks < LinkHum
  def url_params(uri)
    {target: '_blank'} unless uri.domain == 'oursite.com'
  end
end

MyLinks.urlify("http://oursite.com/posts/12345 has been mentioned at http://cnn.com")
# => 
```

You can also define special strings, which should also became URLs on your
site:

```ruby
class MyLinks < LinkHum
  special /@(\S+)\b/ do |username|
    "http://oursite/users/#{username}"
  end
end

MyLinks.urlify("Hey, @jude!")
# => "Hey, <a href='http://oursite/users/jude'>@jude</a>!"

# nil or false means no replacements:
class MyLinks < LinkHum
  special /@(\S+)\b/ do |username|
    "http://oursite/users/#{username}" if User.where(name: username).exists?
  end
end

MyLinks.urlify("So, our @dude and @unknownguy walk into a bar...")
# => "So, our <a href='http://oursite/users/dude'>@dude</a> and @unknownguy walk into a bar..."
```

Some `special` gotchas:
* for now, only one `special` per class is supported (an attempt to define
  additional one will show warningn);
* it passes to the block values by the same logic as `String#scan` does:

```ruby
class AllSymbols < LinkHum
  special /@\S+\b/ do |username|
    p username
    nil
  end
end
AllSymbols.urlify('@dude')
# Receives "@dude"

class SelectedPart < LinkHum
  special /@(\S+)\b/ do |username|
    p username
    nil
  end
end
SelectedPart.urlify('@dude')
# Receives "dude"

class SeveralArgs < LinkHum
  special(/@(\S+)_(\S+)\b/) do |first, second|
    p first, second
    nil
  end
end
SeveralArgs.urlify('@cool_dude')
# Receives "cool", "dude"
```

## Credits

* [squadette](https://github.com/squadette) -- author of original code;
* users of _some secret social network_ -- testing and advicing;
* [zverok](https://github.com/zverok) -- gemifying, documenting and
  writing specs.

## Contributing

Just usual fork-change-pull request process.

### Development

## License

MIT
