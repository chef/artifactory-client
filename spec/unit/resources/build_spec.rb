require "spec_helper"

module Artifactory
  describe Resource::Build do
    let(:client) { double(:client) }
    let(:time) { Time.now.utc.round }

    before(:each) do
      allow(Artifactory).to receive(:client).and_return(client)
      allow(client).to receive(:get).and_return(response) if defined?(response)

      subject.name   = "wicket"
      subject.number = "51"
    end

    describe ".all" do
      let(:response) do
        {
          "uri"           => "#{Artifactory.endpoint}/api/build/wicket",
          "buildsNumbers" => [
            {
              "uri"     => "/51",
              "started" => "2014-01-01 12:00:00",
            },
            {
              "uri"     => "/52",
              "started" => "2015-01-05 12:00:00",
            },
          ],
        }
      end

      before do
        allow(described_class).to receive(:find).with("wicket", "51", client: client).and_return("51")
        allow(described_class).to receive(:find).with("wicket", "52", client: client).and_return("52")
      end

      it 'GETS /api/build/#{name}' do
        expect(client).to receive(:get).with("/api/build/wicket").once
        described_class.all("wicket")
      end

      context "when there are builds" do
        it "returns the builds" do
          expect(described_class.all("wicket")).to eq(%w{51 52})
        end
      end

      context "when the system has no builds" do
        it "returns an empty array" do
          allow(client).to receive(:get).and_raise(Error::HTTPError.new("status" => 404))
          expect(described_class.all("wicket")).to be_empty
        end
      end
    end

    describe ".find" do
      let(:response) { { "buildInfo" => {} } }

      it 'GETS /api/repositories/#{name}/#{number}' do
        expect(client).to receive(:get).with("/api/build/wicket/51").once
        described_class.find("wicket", 51)
      end

      context "when the build does not exist" do
        it "returns nil" do
          allow(client).to receive(:get).and_raise(Error::HTTPError.new("status" => 404))
          expect(described_class.find("wicket", "4445")).to be_nil
        end
      end
    end

    describe ".from_hash" do
      let(:hash) do
        {
          "properties"           => {
            "buildInfo.env.JAVA_HOME" => "/usr/jdk/latest",
          },
          "version"              => "1.0.1",
          "name"                 => "Maven2-3",
          "number"               => "9",
          "type"                 => "MAVEN",
          "buildAgent"           => {
            "name"    => "Maven",
            "version" => "3.0.5",
          },
          "agent"                => {
            "name"    => "Jenkins",
            "version" => "1.565.2",
          },
          "started"              => time.iso8601(3),
          "durationMillis"       => 8926,
          "artifactoryPrincipal" => "admin",
          "url"                  => "http://localhost:8080/job/Maven2-3/9/",
          "vcsRevision"          => "83049487ecc61bef3dce798838e7a9457e174a5a",
          "vcsUrl"               => "https://github.com/aseftel/project-examples",
          "licenseControl"       => {
            "runChecks"                       => false,
            "includePublishedArtifacts"       => false,
            "autoDiscover"                    => true,
            "scopesList"                      => "",
            "licenseViolationsRecipientsList" => "",
          },
          "buildRetention"       => {
            "count"                        => -1,
            "deleteBuildArtifacts"         => true,
            "buildNumbersNotToBeDiscarded" => [],
          },
          "modules"              => modules,
          "governance"           => {
            "blackDuckProperties" => {
              "runChecks"                          => false,
              "includePublishedArtifacts"          => false,
              "autoCreateMissingComponentRequests" => false,
              "autoDiscardStaleComponentRequests"  => false,
            },
          },
        }
      end
      let(:modules) do
        [
          {
            "properties" => {
              "project.build.sourceEncoding" => "UTF-8",
            },
            "id"         => "org.jfrog.test:multi:2.19-SNAPSHOT",
            "artifacts"  => [
              {
                "type" => "pom",
                "sha1" => "045b66ebbf8504002b626f592d087612aca36582",
                "md5"  => "c25542a353dab1089cd186465dc47a68",
                "name" => "multi-2.19-SNAPSHOT.pom",
              },
            ],
          },
          {
            "properties" => {
              "project.build.sourceEncoding" => "UTF-8",
            },
            "id"         => "org.jfrog.test:multi1:2.19-SNAPSHOT",
            "artifacts"  => [
              {
                "type" => "jar",
                "sha1" => "f4c5c9cb3091011ec2a895b3dedd7f10d847361c",
                "md5"  => "d1fd850a3582efba41092c624e0b46b8",
                "name" => "multi1-2.19-SNAPSHOT.jar",
              },
              {
                "type" => "pom",
                "sha1" => "2ddbf9824676f548d637726d3bcbb494ba823090",
                "md5"  => "a64aa7f305f63a85e63a0155ff0fb404",
                "name" => "multi1-2.19-SNAPSHOT.pom",
              },
              {
                "type"   => "jar",
                "sha1"   => "6fdd143a44cea3a2636660c5c266c95c27e50abc",
                "md5"    => "12a1e438f4bef8c4b740fe848a1704a4",
                "id"     => "org.slf4j:slf4j-simple:1.4.3",
                "scopes" => [ "compile" ],
              },
              {
                "type"   => "jar",
                "sha1"   => "496e91f7df8a0417e00cecdba840cdf0e5f2472c",
                "md5"    => "76a412a37c9d18659d2dacccdb1c24ff",
                "id"     => "org.jenkins-ci.lib:dry-run-lib:0.1",
                "scopes" => [ "compile" ],
              },
            ],
          },
          {
            "properties"   => {
              "daversion"                    => "2.19-SNAPSHOT",
              "project.build.sourceEncoding" => "UTF-8",
            },
            "id"           => "org.jfrog.test:multi2:2.19-SNAPSHOT",
            "artifacts"    => [
              {
                "type" => "txt",
                "name" => "multi2-2.19-SNAPSHOT.txt",
              },
              {
                "type" => "java-source-jar",
                "sha1" => "49108b0c7db5fdb4efe3c29a5a9f54e806aecb62",
                "md5"  => "0e2c5473cf2a9b694afb4a2e8da34b53",
                "name" => "multi2-2.19-SNAPSHOT-sources.jar" },
             {
                "type" => "jar",
                "sha1" => "476e89d290ae36dabb38ff22f75f264ae019d542",
                "md5"  => "fa9b3df58ac040fffcff9310f261be80",
                "name" => "multi2-2.19-SNAPSHOT.jar",
             },
             {
                "type" => "pom",
                "sha1" => "b719b90364e5ae38cda358072f61f821bdae5d5d",
                "md5"  => "8d5060005235d75907baca4490cf60bf",
                "name" => "multi2-2.19-SNAPSHOT.pom",
              },
            ],
            "dependencies" => [
              {
                "type"   => "jar",
                "sha1"   => "19d4e90b43059058f6e056f794f0ea4030d60b86",
                "md5"    => "dcd95bcb84b09897b2b66d4684c040da",
                "id"     => "xpp3:xpp3_min:1.1.4c",
                "scopes" => [ "provided" ],
              },
              {
                "type"   => "jar",
                "sha1"   => "e2d866af5518e81282838301b49a1bd2452619d3",
                "md5"    => "e9e4b59c69305ba3698dd61c5dfc4fc8",
                "id"     => "org.jvnet.hudson.plugins:perforce:1.3.7",
                "scopes" => [ "compile" ],
              },
              {
                "type"   => "jar",
                "sha1"   => "6fdd143a44cea3a2636660c5c266c95c27e50abc",
                "md5"    => "12a1e438f4bef8c4b740fe848a1704a4",
                "id"     => "org.slf4j:slf4j-simple:1.4.3",
                "scopes" => [ "compile" ],
              },
              {
                "type"   => "jar",
                "sha1"   => "496e91f7df8a0417e00cecdba840cdf0e5f2472c",
                "md5"    => "76a412a37c9d18659d2dacccdb1c24ff",
                "id"     => "org.jenkins-ci.lib:dry-run-lib:0.1",
                "scopes" => [ "compile" ],
              },
            ],
          },
          {
            "properties" => {
              "project.build.sourceEncoding" => "UTF-8",
            },
            "id"         => "org.jfrog.test:multi3:2.19-SNAPSHOT",
            "artifacts"  => [
              {
                "type" => "java-source-jar",
                "sha1" => "3cd104785167ac37ef999431f308ffef10810348",
                "md5"  => "c683276f8dda97078ae8eb5e26bb3ee5",
                "name" => "multi3-2.19-SNAPSHOT-sources.jar",
              },
              {
                "type" => "war",
                "sha1" => "34aeebeb805b23922d9d05507404533518cf81e4",
                "md5"  => "55af06a2175cfb23cc6dc3931475b57c",
                "name" => "multi3-2.19-SNAPSHOT.war",
              },
              {
                "type"   => "jar",
                "sha1"   => "496e91f7df8a0417e00cecdba840cdf0e5f2472c",
                "md5"    => "76a412a37c9d18659d2dacccdb1c24ff",
                "id"     => "org.jenkins-ci.lib:dry-run-lib:0.1",
                "scopes" => [ "compile" ],
              },
              {
                "type"   => "jar",
                "sha1"   => "7e9978fdb754bce5fcd5161133e7734ecb683036",
                "md5"    => "7df83e09e41d742cc5fb20d16b80729c",
                "id"     => "hsqldb:hsqldb:1.8.0.10",
                "scopes" => [ "runtime" ],
              },
            ],
          },
        ]
      end

      it "creates a new instance" do
        instance = described_class.from_hash(hash)
        expect(instance.properties).to eq("buildInfo.env.JAVA_HOME" => "/usr/jdk/latest")
        expect(instance.version).to eq("1.0.1")
        expect(instance.name).to eq("Maven2-3")
        expect(instance.number).to eq("9")
        expect(instance.type).to eq("MAVEN")
        expect(instance.build_agent).to eq(
          "name" => "Maven",
          "version" => "3.0.5"
        )
        expect(instance.agent).to eq(
          "name" => "Jenkins",
          "version" => "1.565.2"
        )
        expect(instance.started).to eq(time)
        expect(instance.duration_millis).to eq(8926)
        expect(instance.artifactory_principal).to eq("admin")
        expect(instance.url).to eq("http://localhost:8080/job/Maven2-3/9/")
        expect(instance.vcs_revision).to eq("83049487ecc61bef3dce798838e7a9457e174a5a")
        expect(instance.vcs_url).to eq("https://github.com/aseftel/project-examples")
        expect(instance.build_retention).to eq(
          "count" => -1,
          "deleteBuildArtifacts" => true,
          "buildNumbersNotToBeDiscarded" => []
        )
        expect(instance.modules).to eq(
          modules
        )
        expect(instance.governance).to eq(
          "blackDuckProperties" => {
            "runChecks"                          => false,
            "includePublishedArtifacts"          => false,
            "autoCreateMissingComponentRequests" => false,
            "autoDiscardStaleComponentRequests"  => false,
          }
        )
      end
    end

    describe "#diff" do
      it "sends GET to the client with the correct param" do
        expect(client).to receive(:get).with("/api/build/wicket/51?diff=53", {})
        subject.diff("53")
      end
    end

    describe "#promote" do
      let(:to_repo) { "omnibus-stable-local" }
      before do
        Artifactory.username = "doge"
      end

      it "sends POST to the client with promotion JSON" do
        expect(client).to receive(:post).with("/api/build/promote/wicket/51", /"targetRepo"\:"omnibus-stable-local"/, kind_of(Hash))
        subject.promote(to_repo)
      end

      it "Uses the configured Artifactory.username as the default value for `ciUser`" do
        expect(client).to receive(:post).with("/api/build/promote/wicket/51", /"ciUser"\:"doge"/, kind_of(Hash))
        subject.promote(to_repo)
      end
    end

    describe "#save" do

      it "PUTS the build JSON file to the server" do
        expect(client).to receive(:put).with("/api/build", kind_of(Tempfile), "Content-Type" => "application/json")
        subject.save
      end

      context "an invalid build type is provided" do
        before { subject.type = "PIRATE" }

        it "raises an InvalidBuildType error" do
          expect { subject.save }.to raise_error(Error::InvalidBuildType)
        end
      end
    end
  end
end
