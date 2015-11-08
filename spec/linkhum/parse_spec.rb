# encoding: utf-8
describe LinkHum, :parse do
  context 'when just text' do
    let(:text){'Just text, see?'}
    subject{LinkHum.parse(text)}
    it{
      should == [{type: :text, content: 'Just text, see?'}]
    }
  end

  context 'when URLs with punctuations and stuff' do
    let(:text){'So, it parses URLs like http://google.com/, or http://пивбар.рф/wtf?'}
    subject{LinkHum.parse(text)}
    it{should == [
      {type: :text, content: 'So, it parses URLs like '},
      {type: :url , content: 'http://google.com/'},
      {type: :text, content: ', or '},
      {type: :url , content: 'http://пивбар.рф/wtf'},
      {type: :text, content: '?'}
    ]}
  end

  context 'when specials' do
    context 'one' do
      let(:klass){
        Class.new(described_class){
          special /@(\S+)\b/, :username do |username|
            "http://oursite/users/#{username}" if username == 'dude'
          end
        }
      }
      let(:text){"It's @dude and @someguy"}
      subject{klass.parse(text)}
      it{should == [
        {type: :text, content: "It's "},
        {type: :username, content: '@dude', captures: ['dude']},
        {type: :text, content: ' and '},
        {type: :username, content: '@someguy', captures: ['someguy']},
      ]}
    end

    context 'several' do
      let(:klass){
        Class.new(described_class){
          special /@(\S+)\b/, :username

          special /\#(\S+)\b/, :tag
        }
      }
      let(:text){"It's @dude and @someguy, they are #cute"}
      subject{klass.parse(text)}
      it{should == [
        {type: :text, content: "It's "},
        {type: :username, content: '@dude', captures: ['dude']},
        {type: :text, content: ' and '},
        {type: :username, content: '@someguy', captures: ['someguy']},
        {type: :text, content: ', they are '},
        {type: :tag, content: '#cute', captures: ['cute']},
      ]}
    end

    context 'unnamed' do
      let(:klass){
        Class.new(described_class){
          special /@(\S+)\b/, :username

          special /\#(\S+)\b/
        }
      }
      let(:text){"It's @dude and @someguy, they are #cute"}
      subject{klass.parse(text)}
      it{should == [
        {type: :text, content: "It's "},
        {type: :username, content: '@dude', captures: ['dude']},
        {type: :text, content: ' and '},
        {type: :username, content: '@someguy', captures: ['someguy']},
        {type: :text, content: ', they are '},
        {type: :special_2, content: '#cute', captures: ['cute']},
      ]}
    end

  end
end
