require 'spec_helper'

module Artifactory
  describe Resource::Base do
    describe '.attribute' do
      before { described_class.attribute(:bacon) }

      it 'defines an accessor method' do
        expect(subject).to respond_to(:bacon)
      end

      it 'defines a setter method' do
        expect(subject).to respond_to(:bacon=)
      end

      it 'defines a boolean method' do
        expect(subject).to respond_to(:bacon?)
      end
    end

    describe '.extract_client!' do
      context 'when the :client key is present' do
        let(:client) { double }
        let(:options) { { client: client } }

        it 'extracts the client' do
          result = described_class.extract_client!(options)
          expect(result).to be(client)
        end

        it 'removes the key from the hash' do
          described_class.extract_client!(options)
          expect(options).to_not have_key(:client)
        end
      end

      context 'when the :client key is not present' do
        let(:client) { double }
        before { allow(Artifactory).to receive(:client).and_return(client) }

        it 'uses Artifactory.client' do
          expect(described_class.extract_client!({})).to be(client)
        end
      end
    end

    describe '.format_repos!' do
      context 'when the :repos key is present' do
        it 'joins an array' do
          options = { repos: ['bacon', 'bits'] }
          described_class.format_repos!(options)
          expect(options[:repos]).to eq('bacon,bits')
        end

        it 'accepts a single repository' do
          options = { repos: 'bacon' }
          described_class.format_repos!(options)
          expect(options[:repos]).to eq('bacon')
        end
      end

      context 'when the :repos key is not present' do
        it 'does not modify the hash' do
          options = {}
          described_class.format_repos!(options)
          expect(options).to eq(options)
        end
      end

      context 'when the :repos key is empty' do
        it 'does not modify the hash' do
          options = { repos: [] }
          described_class.format_repos!(options)
          expect(options).to eq(options)
        end
      end

      describe '.url_safe' do
        let(:string) { double(to_s: 'string') }

        it 'delegates to URI.escape' do
          expect(URI).to receive(:escape).once
          described_class.url_safe(string)
        end

        it 'converts the value to a string' do
          expect(string).to receive(:to_s).once
          described_class.url_safe(string)
        end
      end
    end

    describe '#client' do
      it 'defines a :client method' do
        expect(subject).to respond_to(:client)
      end

      it 'defaults to the Artifactory.client' do
        client = double
        allow(Artifactory).to receive(:client).and_return(client)

        expect(subject.client).to be(client)
      end
    end

    describe '#extract_client!' do
      it 'delegates to the class method' do
        expect(described_class).to receive(:extract_client!).once
        subject.extract_client!({})
      end
    end

    describe '#format_repos!' do
      it 'delegates to the class method' do
        expect(described_class).to receive(:format_repos!).once
        subject.format_repos!({})
      end
    end

    describe '#url_safe' do
      it 'delegates to the class method' do
        expect(described_class).to receive(:url_safe).once
        subject.url_safe('string')
      end
    end

    describe '#to_s' do
      it 'returns the name of the class' do
        expect(subject.to_s).to eq('#<Base>')
      end
    end

    describe '#inspect' do
      it 'includes all the attributes' do
        allow(subject).to receive(:attributes) do
          { foo: 'bar' }
        end

        expect(subject.inspect).to eq(%q|#<Base foo: "bar">|)
      end
    end
  end
end
