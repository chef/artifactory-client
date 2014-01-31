require 'spec_helper'

module Artifactory
  describe Client do
    let(:client) { subject }

    context 'configuration' do
      it 'is a configurable object' do
        expect(client).to be_a(Configurable)
      end

      it 'users the default configuration' do
        Defaults.options.each do |key, value|
          expect(client.send(key)).to eq(value)
        end
      end

      it 'uses the values in the initializer' do
        client = described_class.new(username: 'admin')
        expect(client.username).to eq('admin')
      end

      it 'can be modified after initialization' do
        expect(client.username).to eq(Defaults.username)
        client.username = 'admin'
        expect(client.username).to eq('admin')
      end
    end

    describe '.proxy' do
      before { described_class.proxy(Resource::Artifact) }

      it 'defines a new method' do
        expect(described_class).to be_method_defined(:artifact_search)
      end

      it 'delegates to the class, injecting the client' do
        Resource::Artifact.stub(:search)
        expect(Resource::Artifact).to receive(:search).with(client: subject)
        subject.artifact_search
      end
    end

    describe '#agent' do
      it 'acts like an HTTPClient' do
        expect(client.agent).to be_a(HTTPClient)
      end

      it 'caches the agent' do
        agent = Artifactory.client.agent
        expect(agent).to be(Artifactory.client.agent)
      end

      it 'sets basic auth if given' do
        subject.username = 'admin'
        subject.password = 'password'
        expect(subject.agent.www_auth.basic_auth).to be_a(HTTPClient::BasicAuth)
      end

      it 'sets the proxy if given' do
        subject.proxy = 'http://admin:password@localhost'
        expect(subject.agent.proxy.to_s).to eq('http://admin:password@localhost')
      end
    end

    describe '#get' do
      it 'delegates to the #request method' do
        expect(subject).to receive(:request).with(:get, '/foo')
        subject.get('/foo')
      end
    end

    describe '#post' do
      it 'delegates to the #request method' do
        expect(subject).to receive(:request).with(:post, '/foo')
        subject.post('/foo')
      end
    end

    describe '#put' do
      it 'delegates to the #request method' do
        expect(subject).to receive(:request).with(:put, '/foo')
        subject.put('/foo')
      end
    end

    describe '#patch' do
      it 'delegates to the #request method' do
        expect(subject).to receive(:request).with(:patch, '/foo')
        subject.patch('/foo')
      end
    end

    describe '#delete' do
      it 'delegates to the #request method' do
        expect(subject).to receive(:request).with(:delete, '/foo')
        subject.delete('/foo')
      end
    end

    describe '#head' do
      it 'delegates to the #request method' do
        expect(subject).to receive(:request).with(:head, '/foo')
        subject.head('/foo')
      end
    end

    describe '#request' do
      # it 'transforms relative URLs' do
      #   request = client.request(:get, '/api/system/info')
      #   expect(request.url).to eq("#{client.endpoint}/api/system/info")
      # end

      # it 'does not transform absolute URLs' do
      #   request = client.request(:get, 'https://github.com')
      #   expect(request.url).to eq('https://github.com')
      # end

      context 'when the response is a 400' do
        before { stub_request(:get, /.+/).to_return(status: 400) }

        it 'raises a BadRequest error' do
          expect { subject.request(:get, '/') }.to raise_error(Error::BadRequest)
        end
      end

      context 'when the response is a 401' do
        before { stub_request(:get, /.+/).to_return(status: 401) }

        it 'raises a Unauthorized error' do
          expect { subject.request(:get, '/') }.to raise_error(Error::Unauthorized)
        end
      end

      context 'when the response is a 403' do
        before { stub_request(:get, /.+/).to_return(status: 403) }

        it 'raises a Forbidden error' do
          expect { subject.request(:get, '/') }.to raise_error(Error::Forbidden)
        end
      end

      context 'when the response is a 404' do
        before { stub_request(:get, /.+/).to_return(status: 404) }

        it 'raises a NotFound error' do
          expect { subject.request(:get, '/') }.to raise_error(Error::NotFound)
        end
      end

      context 'when the response is a 405' do
        before { stub_request(:get, /.+/).to_return(status: 405) }

        it 'raises a MethodNotAllowed error' do
          expect { subject.request(:get, '/') }.to raise_error(Error::MethodNotAllowed)
        end
      end

      context 'when the response is a 500' do
        before { stub_request(:get, /.+/).to_return(status: 500) }

        it 'raises a ConnectionError error' do
          expect { subject.request(:get, '/') }.to raise_error(Error::ConnectionError)
        end
      end

      context 'when something really bad happens' do
        before { stub_request(:get, /.+/).to_raise(SocketError) }

        it 'converts to a ConnectionError' do
          expect { subject.request(:get, '/') }.to raise_error(Error::ConnectionError)
        end
      end
    end
  end
end
