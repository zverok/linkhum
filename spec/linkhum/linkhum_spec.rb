# encoding: utf-8
describe LinkHum do
  context 'basics' do
    let(:text){'So, it parses URLs like http://google.com/, or http://пивбар.рф/wtf?'}
    subject{described_class.urlify(text)}
    it{should ==
      "So, it parses URLs like <a href='http://google.com/'>http://google.com/</a>, or <a href='http://пивбар.рф/wtf'>http://пивбар.рф/wtf</a>?"
    }
  end
  
  context 'proper parsing' do
    EXAMPLES = YAML.load(File.read('spec/fixtures/examples.yml'))

    EXAMPLES.each do |ex|
      context "when \"#{ex['text']}\"" do
        let(:urlified){
          described_class.urlify(ex['text'])
        }
        let(:urls){[*ex['urls']]}

        subject{
          Nokogiri::HTML(urlified).search('a').map{|a| a.attr('href')}
        }
        it{should == urls}
      end
    end
  end

  context 'url shortening' do
    it 'does nothing with short urls' do
      expect(described_class.urlify('http://google.com')).to eq \
        "<a href='http://google.com'>http://google.com</a>"
    end

    it 'shortens long urls' do
      expect(described_class.urlify('http://www.booking.com/searchresults.html?sid=79b5eeb441120b08fcd3ebe467b0a0b8;dcid=1;bb_asr=2&class_interval=1&csflt=%7B%7D&dest_id=-2167973&dest_type=city&dtdisc=0&group_adults=2&group_children=0&hlrd=0&hyb_red=0&idf=1&inac=0&nha_red=0&no_rooms=1&offset=0&redirected_from_city=0&redirected_from_landmark=0&redirected_from_region=0&review_score_group=empty&score_min=0&si=ai,co,ci,re,di&src=index&ss=Lisbon,%20Lisbon%20Region,%20Portugal&ss_all=0&ss_raw=Lisbon&ssb=empty&sshis=0')).to eq \
        "<a href='http://www.booking.com/searchresults.html?sid=79b5eeb441120b08fcd3ebe467b0a0b8;dcid=1;bb_asr=2&class_interval=1&csflt=%7B%7D&dest_id=-2167973&dest_type=city&dtdisc=0&group_adults=2&group_children=0&hlrd=0&hyb_red=0&idf=1&inac=0&nha_red=0&no_rooms=1&offset=0&redirected_from_city=0&redirected_from_landmark=0&redirected_from_region=0&review_score_group=empty&score_min=0&si=ai,co,ci,re,di&src=index&ss=Lisbon,%20Lisbon%20Region,%20Portugal&ss_all=0&ss_raw=Lisbon&ssb=empty&sshis=0'>http://www.booking.com/searchresults.html?sid=79b5eeb441120b0...</a>"
    end

    it 'allows to set limit' do
      expect(described_class.urlify('http://google.com', max_length: 12)).to eq \
        "<a href='http://google.com'>http://go...</a>"
    end
  end

  context 'additional link attrs' do
  end

  context 'special patterns' do
  end
end
