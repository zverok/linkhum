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
# =>

# But processes it inside:
LinkHum.urlify('Watch this: https://www.youtube.com/watch?v=Q9Dv4Hmf_O8')
# =>

# Understands parentheses:
LinkHum.urlify("It's a movie: https://en.wikipedia.org/wiki/Hours_(2013_film) It's just parens: (https://www.youtube.com/watch?v=Q9Dv4Hmf_O8)")
# =>

# URL shortening:
LinkHum.urlify("It's too long: http://www.booking.com/searchresults.ru.html?sid=28c7356c8d0fb6d81de3a45eff97e0fe;dcid=4;bb_asr=2&class_interval=1&csflt=%7B%7D&dest_id=-2167973&dest_type=city&group_adults=2&group_children=0&idf=1&label_click=undef&no_rooms=1&offset=0&review_score_group=empty&score_min=0&si=ai%2Cco%2Cci%2Cre%2Cdi&src=index&ss=Lisbon%2C%20Lisbon%20Region%2C%20Portugal&ss_raw=Lisbon&ssb=empty")
# =>

# It's customizable:
LinkHum.urlify(
  "It's too long: http://www.booking.com/searchresults.ru.html?sid=28c7356c8d0fb6d81de3a45eff97e0fe;dcid=4;bb_asr=2&class_interval=1&csflt=%7B%7D&dest_id=-2167973&dest_type=city&group_adults=2&group_children=0&idf=1&label_click=undef&no_rooms=1&offset=0&review_score_group=empty&score_min=0&si=ai%2Cco%2Cci%2Cre%2Cdi&src=index&ss=Lisbon%2C%20Lisbon%20Region%2C%20Portugal&ss_raw=Lisbon&ssb=empty",
  max_length: 10)
# =>

# Non-ASCII domains and paths:
LinkHum.urlify("Domain: http://www.詹姆斯.com/, and path: https://ru.wikipedia.org/wiki/Эффект_Даннинга_—_Крюгера")
# =>

# Look, ma, no XSS!
LinkHum.urlify('http://example.com/foo?">here.</a><script>window.alert("wow");</script>')
# => 
```


## Customization

### On the fly

Custom URL params:

```ruby
LinkHum.urlify("http://oursite.com/posts/12345 has been mentioned at http://cnn.com"){
  |uri|
  uri.domain == 'oursite.com' ? {} : {target: '_blank'}
}
# => 
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
# => 
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
