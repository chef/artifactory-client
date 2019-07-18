require "spec_helper"

module Artifactory
  describe Resource::Certificate do
    let(:client) { double(:client) }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)
    end

    describe ".all" do
      let(:response) do
        %w{a b c}
      end
      before do
        allow(described_class).to receive(:from_hash).with("a", client: client).and_return("a")
        allow(described_class).to receive(:from_hash).with("b", client: client).and_return("b")
        allow(described_class).to receive(:from_hash).with("c", client: client).and_return("c")
      end

      it "gets /api/system/security/certificates" do
        expect(client).to receive(:get).with("/api/system/security/certificates").once
        described_class.all
      end

      it "returns the certificates" do
        expect(described_class.all).to eq(%w{a b c})
      end
    end

    describe ".from_hash" do
      let(:hash) do
        {
          "certificateAlias" => "test",
          "issuedTo"         => "An end user",
          "issuedBy"         => "An authority",
          "issuedOn"         => "2014-01-01 10:00 UTC",
          "validUntil"       => "2014-01-01 11:00 UTC",
          "fingerprint"      => "00:01:02:03:04:05:06:07:08:09:0A:0B:0C:0D:0E:0F",
        }
      end

      it "creates a new instance" do
        instance = described_class.from_hash(hash)
        expect(instance.certificate_alias).to eq("test")
        expect(instance.issued_to).to eq("An end user")
        expect(instance.issued_by).to eq("An authority")
        expect(instance.issued_on).to eq(Time.parse("2014-01-01 10:00 UTC"))
        expect(instance.valid_until).to eq(Time.parse("2014-01-01 11:00 UTC"))
        expect(instance.fingerprint).to eq("00:01:02:03:04:05:06:07:08:09:0A:0B:0C:0D:0E:0F")
      end
    end

    describe "#upload" do
      let(:client)     { double(put: {}) }
      let(:local_path) { "/local/path" }
      let(:file)       { double(File) }

      subject { described_class.new(client: client, local_path: local_path, certificate_alias: "test") }

      before do
        allow(File).to receive(:new).with(/\A(\w:)?#{local_path}\z/).and_return(file)
      end

      context "when the certificate is a file path" do
        it "POSTs the file at the path to the server" do
          expect(client).to receive(:post).with("/api/system/security/certificates/test", file, { "Content-Type" => "application/text" })
          subject.upload
        end
      end
    end
  end
end
