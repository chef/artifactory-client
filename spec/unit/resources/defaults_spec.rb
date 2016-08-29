require "spec_helper"

module Artifactory
  describe Defaults do
    describe "read_timeout" do
      before(:each) do
        ENV['ARTIFACTORY_READ_TIMEOUT'] = "60"
      end

      after(:each) do
        ENV.delete('ARTIFACTORY_READ_TIMEOUT')
      end

      it "returns Fixnums even when given strings" do
        expect(subject.read_timeout).to be_an_instance_of Fixnum
      end
    end
  end
end