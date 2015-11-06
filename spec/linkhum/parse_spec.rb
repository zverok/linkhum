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
    it{should ==
      [
        {type: :text, content: 'So, it parses URLs like '},
        {type: :url , content: 'http://google.com/'},
        {type: :text, content: ', or '},
        {type: :url , content: 'http://пивбар.рф/wtf'},
        {type: :text, content: '?'}
      ]
    }
  end

  context 'when specials' do
  end
end
