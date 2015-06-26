# encoding: utf-8
describe LinkHum do
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
  end

  context 'additional params' do
  end

  context 'special patterns' do
  end
end
