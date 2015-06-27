Gem::Specification.new do |s|
  s.name     = 'linkhum'
  s.version  = '0.0.1'
  s.authors  = ['Alexey Makhotkin', 'Victor Shepelev']
  s.email    = 'zverok.offline@gmail.com'
  s.homepage = 'https://github.com/zverok/linkhum'

  s.summary = 'Humane link urlifier'
  s.licenses = ['MIT']

  s.files = `git ls-files`.split($RS).reject do |file|
    file =~ /^(?:
    spec\/.*
    |Gemfile
    |Rakefile
    |\.rspec
    |\.gitignore
    |\.rubocop.yml
    |\.travis.yml
    )$/x
  end
  s.require_paths = ["lib"]

  s.add_dependency 'addressable'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 3'
  s.add_development_dependency 'rspec-its', '~> 1'
  s.add_development_dependency 'nokogiri'
  s.add_development_dependency 'rubocop'
  #s.add_development_dependency 'dokaz'
end
