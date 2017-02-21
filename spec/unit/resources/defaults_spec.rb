require "spec_helper"

module Artifactory
  describe Defaults do
    describe "read_timeout" do
      before(:each) do
        ENV["ARTIFACTORY_READ_TIMEOUT"] = "60"
      end

      after(:each) do
        ENV.delete("ARTIFACTORY_READ_TIMEOUT")
      end

      it "returns Integers even when given strings" do
        expect(subject.read_timeout).to be_kind_of Integer
      end

      it "returns a non-zero value" do
        expect(subject.read_timeout).to be > 0
      end

      it "does not return a nil value" do
        expect(subject.read_timeout).not_to be nil
      end
    end
  end
end
