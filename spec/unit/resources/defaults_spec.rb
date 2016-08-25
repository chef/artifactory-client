require "spec_helper"

module Artifactory
  describe Defaults do
    describe "read_timeout" do
      it "returns Fixnums even when given strings" do
        begin
          original_timeout = ENV['ARTIFACTORY_READ_TIMEOUT']
          ENV['ARTIFACTORY_READ_TIMEOUT'] = "60"

          expect(subject.read_timeout).to be_an_instance_of Fixnum
        ensure
          if original_timeout.nil?
            ENV.delete 'ARTIFACTORY_READ_TIMEOUT'
          else
            ENV['ARTIFACTORY_READ_TIMEOUT'] = original_timeout
          end
        end
      end
    end
  end
end