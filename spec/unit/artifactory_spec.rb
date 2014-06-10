require 'spec_helper'

describe Artifactory do
  it 'sets the default values' do
    Artifactory::Configurable.keys.each do |key|
      value = Artifactory::Defaults.send(key)
      expect(Artifactory.instance_variable_get(:"@#{key}")).to eq(value)
    end
  end

  describe '.client' do
    it 'creates an Artifactory::Client' do
      expect(Artifactory.client).to be_a(Artifactory::Client)
    end

    it 'caches the client when the same options are passed' do
      expect(Artifactory.client).to eq(Artifactory.client)
    end

    it 'returns a fresh client when options are not the same' do
      original_client = Artifactory.client

      # Change settings
      Artifactory.username = 'admin'
      new_client = Artifactory.client

      # Get it one more tmie
      current_client = Artifactory.client

      expect(original_client).to_not eq(new_client)
      expect(new_client).to eq(current_client)
    end
  end

  describe '.configure' do
    Artifactory::Configurable.keys.each do |key|
      it "sets the #{key.to_s.gsub('_', ' ')}" do
        Artifactory.configure do |config|
          config.send("#{key}=", key)
        end

        expect(Artifactory.instance_variable_get(:"@#{key}")).to eq(key)
      end
    end
  end

  describe '.method_missing' do
    context 'when the client responds to the method' do
      let(:client) { double(:client) }
      before { allow(Artifactory).to receive(:client).and_return(client) }

      it 'delegates the method to the client' do
        allow(client).to receive(:bacon).and_return('awesome')
        expect { Artifactory.bacon }.to_not raise_error
      end
    end

    context 'when the client does not respond to the method' do
      it 'calls super' do
        expect { Artifactory.bacon }.to raise_error(NoMethodError)
      end
    end
  end

  describe '.respond_to_missing?' do
    let(:client) { double(:client) }
    before { allow(Artifactory).to receive(:client).and_return(client) }

    it 'delegates to the client' do
      expect { Artifactory.respond_to_missing?(:foo) }.to_not raise_error
    end
  end
end
