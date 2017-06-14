require "spec_helper"

module Artifactory
  describe Client do
    let(:client) { subject }

    context "configuration" do
      it "is a configurable object" do
        expect(client).to be_a(Configurable)
      end

      it "users the default configuration" do
        Defaults.options.each do |key, value|
          expect(client.send(key)).to eq(value)
        end
      end

      it "uses the values in the initializer" do
        client = described_class.new(username: "admin")
        expect(client.username).to eq("admin")
      end

      it "can be modified after initialization" do
        expect(client.username).to eq(Defaults.username)
        client.username = "admin"
        expect(client.username).to eq("admin")
      end
    end

    describe ".proxy" do
      before { described_class.proxy(Resource::Artifact) }

      it "defines a new method" do
        expect(described_class).to be_method_defined(:artifact_search)
      end

      it "delegates to the class, injecting the client" do
        allow(Resource::Artifact).to receive(:search)
        expect(Resource::Artifact).to receive(:search).with(client: subject)
        subject.artifact_search
      end
    end

    describe "#get" do
      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:get, "/foo", {}, {})
        subject.get("/foo")
      end

      context "called with a block" do
        it "yields the response in chunks" do
          expect(subject).to receive(:request).with(:get, "/foo", {}, {}) { |&block| block.call("Chunked Body") }
          expect { |chunk| subject.get("/foo", &chunk) }.to yield_with_args("Chunked Body")
        end
      end
    end

    describe "#post" do
      let(:data) { double }

      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:post, "/foo", data, {})
        subject.post("/foo", data)
      end
    end

    describe "#put" do
      let(:data) { double }

      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:put, "/foo", data, {})
        subject.put("/foo", data)
      end
    end

    describe "#patch" do
      let(:data) { double }

      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:patch, "/foo", data, {})
        subject.patch("/foo", data)
      end
    end

    describe "#delete" do
      it "delegates to the #request method" do
        expect(subject).to receive(:request).with(:delete, "/foo", {}, {})
        subject.delete("/foo")
      end
    end

    describe "#request" do
      context "when the response is a 400" do
        before { stub_request(:get, /.+/).to_return(status: 5000, body: "No!") }

        it "raises an HTTPError error" do
          expect { subject.request(:get, "/") }.to raise_error(Error::HTTPError)
        end
      end

      context "called with a block" do
        before { stub_request(:get, /.+/).to_return(status: 200, body: "Chunked Body") }

        it "yields the response in chunks" do
          subject.request(:get, "/foo") do |chunk|
            expect(chunk).to eq("Chunked Body")
          end
        end
      end

      context "application/json response with an empty body" do
        before { stub_request(:get, /.+/).to_return(status: 200, headers: { "Content-Type" => "application/json" }, body: "") }

        it "should not raise an error" do
          expect { subject.request(:get, "/foo") }.to_not raise_error(TypeError)
        end
      end
    end

    describe "#to_query_string" do
      it 'converts spaces to "+" characters' do
        params = { user: "Seth Chisamore" }
        expect(subject.to_query_string(params)).to eq("user=Seth+Chisamore")
      end

      it 'converts "+" to "%2B"' do
        params = { version: "12.0.0-alpha.1+20140826080510.git.50.f5ff271" }
        expect(subject.to_query_string(params)).to eq("version=12.0.0-alpha.1%2B20140826080510.git.50.f5ff271")
      end
    end
  end
end
