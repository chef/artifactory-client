#
# Copyright 2014 Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'artifactory/resources/repository_base'

module Artifactory
  class Resource::Repository < Resource::Base
    include Artifactory::Resource::RepositoryBase

    attribute :blacked_out, false
    attribute :description
    attribute :checksum_policy_type, 'client-checksums'
    attribute :excludes_pattern, ''
    attribute :handle_releases, true
    attribute :handle_snapshots, true
    attribute :includes_pattern, '**/*'
    attribute :max_unique_snapshots, 0
    attribute :notes
    attribute :property_sets, []
    attribute :repo_layout_ref, 'maven-2-default'
    attribute :rclass, 'local'
    attribute :snapshot_version_behavior, 'non-unique'
    attribute :suppress_pom_consistency_checks, false

    #
    # Upload to a given repository
    #
    # @see Artifact#upload Upload syntax examples
    #
    # @return [Resource::Artifact]
    #
    def upload(local_path, remote_path, properties = {}, headers = {})
      artifact = Resource::Artifact.new(local_path: local_path)
      artifact.upload(key, remote_path, properties, headers)
    end

    #
    # Upload an artifact with the given SHA checksum. Consult the artifactory
    # documentation for the possible responses when the checksums fail to
    # match.
    #
    # @see Artifact#upload_with_checksum More syntax examples
    #
    def upload_with_checksum(local_path, remote_path, checksum, properties = {})
      artifact = Resource::Artifact.new(local_path: local_path)
      artifact.upload_with_checksum(key, remote_path, checksum, properties)
    end

    #
    # Upload an artifact with the given archive. Consult the artifactory
    # documentation for the format of the archive to upload.
    #
    # @see Artifact#upload_from_archive More syntax examples
    #
    def upload_from_archive(local_path, remote_path, properties = {})
      artifact = Resource::Artifact.new(local_path: local_path)
      artifact.upload_from_archive(key, remote_path, properties)
    end

    #
    # The list of artifacts in this repository on the remote artifactory
    # server.
    #
    # @see Artifact.search Search syntax examples
    #
    # @example Get the list of artifacts for a repository
    #   repo = Repository.new('libs-release-local')
    #   repo.artifacts #=> [#<Resource::Artifacts>, ...]
    #
    # @return [Collection::Artifact]
    #   the list of artifacts
    #
    def artifacts
      @artifacts ||= Collection::Artifact.new(self, repos: key) do
        Resource::Artifact.search(name: '.*', repos: key)
      end
    end

    #
    #
    #
    def files
      response = client.get("/api/storage/#{url_safe(key)}", {
        deep:            0,
        listFolders:     0,
        mdTimestamps:    0,
        includeRootPath: 0,
      })

      response['children']
    end



    private
    #
    # The default Content-Type for this repository. It varies based on the
    # repository type.
    #
    # @return [String]
    #
    def content_type
      case rclass.to_s.downcase
      when 'local'
        'application/vnd.org.jfrog.artifactory.repositories.LocalRepositoryConfiguration+json'
      when 'remote'
        'application/vnd.org.jfrog.artifactory.repositories.RemoteRepositoryConfiguration+json'
      when 'virtual'
        'application/vnd.org.jfrog.artifactory.repositories.VirtualRepositoryConfiguration+json'
      else
        raise "Unknown Repository type `#{rclass}'!"
      end
    end
  end
end
