require 'spec_helper'

module Artifactory
  describe Request do
    subject { described_class.new(:get, 'http://localhost:8080') }

    describe '#verb' do
      it 'gets the uppercase string verb' do
        request = described_class.new(:get, nil)
        expect(request.verb).to eq('GET')
      end
    end

    describe '#body' do
      let(:response) { double(body: 'This is the body...') }
      before { subject.stub(:response).and_return(response) }

      its(:body) { should eq(response.body) }
    end

    describe '#code' do
      before { subject.stub(:response).and_return(response) }

      context 'when the response is an integer' do
        let(:response) { double(code: 200) }
        its(:code) { should eq(200) }
      end

      context 'when the response is a string' do
        let(:response) { double(code: '200') }
        its(:code) { should eq(200) }
      end
    end

    describe '#ok?' do
      before { subject.stub(:response).and_return(response) }

      (200..399).each do |code|
        context "when the status code is #{code}" do
          let(:response) { double(code: code) }
          its(:ok?) { should be_true }
        end
      end

      (400..599).each do |code|
        context "when the status code is #{code}" do
          let(:response) { double(code: code) }
          its(:ok?) { should be_false }
        end
      end
    end

    describe '#json' do
      before { subject.stub(:response).and_return(response) }

      context 'when the response is valid JSON' do
        let(:response) { double(body: '{"foo": "bar"}') }
        its(:json) { should eq('foo' => 'bar') }
      end

      context 'when the response is not valid JSON' do
        let(:response) { double(body: 'Totally not json!') }

        it 'should raise a parser error' do
          expect { subject.json }.to raise_error(JSON::ParserError)
        end
      end
    end

    describe '#xml' do
      let(:response) { double(body: '<foo>bar</foo>') }
      before { subject.stub(:response).and_return(response) }

      its(:xml) { should be_a(REXML::Document) }
    end

    describe '#response' do
      let(:response) { double(status: status, body: 'An error...') }
      subject { described_class.new(nil, nil, &->{ response }) }

      context 'when the response is a 400' do
        let(:status) { 400 }

        it 'raises a BadRequest error' do
          expect { subject.response }.to raise_error(Error::BadRequest)
        end
      end

      context 'when the response is a 401' do
        let(:status) { 401 }

        it 'raises a Unauthorized error' do
          expect { subject.response }.to raise_error(Error::Unauthorized)
        end
      end

      context 'when the response is a 403' do
        let(:status) { 403 }

        it 'raises a Forbidden error' do
          expect { subject.response }.to raise_error(Error::Forbidden)
        end
      end

      context 'when the response is a 404' do
        let(:status) { 404 }

        it 'raises a NotFound error' do
          expect { subject.response }.to raise_error(Error::NotFound)
        end
      end

      context 'when the response is a 405' do
        let(:status) { 405 }

        it 'raises a MethodNotAllowed error' do
          expect { subject.response }.to raise_error(Error::MethodNotAllowed)
        end
      end

      context 'when the response is a 500' do
        let(:status) { 500 }

        it 'raises a ConnectionError error' do
          expect { subject.response }.to raise_error(Error::ConnectionError)
        end
      end

      context 'when something really bad happens' do
        subject { described_class.new(nil, nil, &->{ raise EOFError }) }

        it 'converts to a ConnectionError' do
          expect { subject.response }.to raise_error(Error::ConnectionError)
        end
      end
    end

    describe '#to_s' do
      it 'returns the string form' do
        expect(subject.to_s).to eq('#<Artifactory::Request GET http://localhost:8080>')
      end
    end

    describe '#inspect' do
      let(:response) { double(status: 'OK', code: 200) }
      subject { described_class.new(:get, 'http://localhost:8080', &->{ response }) }

      context 'when the request has not been made' do
        it 'returns the string form' do
          expect(subject.inspect).to eq('#<Artifactory::Request GET http://localhost:8080 (pending)>')
        end
      end

      context 'when the request has been made' do
        it 'returns the string form' do
          subject.response
          expect(subject.inspect).to eq('#<Artifactory::Request GET http://localhost:8080 (200)>')
        end
      end
    end
  end
end
