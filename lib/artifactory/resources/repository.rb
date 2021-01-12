#
# Copyright 2014-2018 Chef Software, Inc.
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

module Artifactory
  class Resource::Repository < Resource::Base
    class << self
      #
      # Get a list of all repositories in the system.
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Array<Resource::Repository>]
      #   the list of builds
      #
      def all(options = {})
        client = extract_client!(options)
        client.get("/api/repositories").map do |hash|
          find(hash["key"], client: client)
        end.compact
      end

      #
      # Find (fetch) a repository by name.
      #
      # @example Find a repository by named key
      #   Repository.find(name: 'libs-release-local') #=> #<Resource::Artifact>
      #
      # @param [Hash] options
      #   the list of options
      #
      # @option options [String] :name
      #   the name of the repository to find
      # @option options [Artifactory::Client] :client
      #   the client object to make the request with
      #
      # @return [Resource::Repository, nil]
      #   an instance of the repository that matches the given name, or +nil+
      #   if one does not exist
      #
      def find(name, options = {})
        client = extract_client!(options)

        response = client.get("/api/repositories/#{url_safe(name)}")
        from_hash(response, client: client)
      rescue Error::HTTPError => e
        raise unless e.code == 400

        nil
      end
    end

    # These can be automatically generated using this procedure
    #
    #   1. Download https://www.jfrog.com/confluence/display/JFROG/Repository+Configuration+JSON
    #   2. Download https://www.jfrog.com/confluence/display/JFROG/Repository+Configuration+JSON
    #

    attribute :allow_any_host_auth
    attribute :archive_browsing_enabled
    attribute :artifactory_requests_can_retrieve_remote_artifacts
    attribute :assumed_offline_period_secs
    attribute :blacked_out, false
    attribute :block_mismatching_mime_types
    attribute :block_pushing_schema1
    attribute :bower_registry_url
    attribute :bypass_head_requests
    attribute :calculate_yum_metadata, false
    attribute :cdn_redirect
    attribute :checksum_policy_type, "client-checksums"
    attribute :client_tls_certificate, ""
    attribute :composer_registry_url
    attribute :content_synchronisation
    attribute :debian_trivial_layout, false
    attribute :default_deployment_repo
    attribute :description
    attribute :docker_api_version, 'V2'
    attribute :download_context_path
    attribute :download_redirect, false
    attribute :enable_cookie_management
    attribute :enable_file_lists_indexing, "false"
    attribute :enable_token_authentication
    attribute :excludes_pattern, ""
    attribute :external_dependencies_enabled, false
    attribute :external_dependencies_patterns
    attribute :external_dependencies_remote_repo
    attribute :feed_context_path
    attribute :fetch_jars_eagerly
    attribute :fetch_sources_eagerly
    attribute :handle_releases, true
    attribute :handle_snapshots, true
    attribute :hard_fail
    attribute :includes_pattern, "**/*"
    attribute :key, -> { raise "Key is missing!" }
    attribute :key_pair
    attribute :key_pair_ref
    attribute :local_address
    attribute :max_unique_snapshots, 0
    attribute :max_unique_tags, 0
    attribute :missed_retrieval_cache_period_secs
    attribute :notes
    attribute :offline
    attribute :optional_index_compression_formats
    attribute :package_type, "generic"
    attribute :password
    attribute :pom_repository_references_cleanup_policy
    attribute :property_sets, []
    attribute :proxy
    attribute :py_pi_registry_url
    attribute :rclass, "local"
    attribute :remote_repo_checksum_policy_type
    attribute :repo_layout_ref, "maven-2-default"
    attribute :repositories, []
    attribute :retrieval_cache_period_secs
    attribute :share_configuration
    attribute :snapshot_version_behavior, "non-unique"
    attribute :socket_timeout_millis
    attribute :store_artifacts_locally
    attribute :suppress_pom_consistency_checks, false
    attribute :synchronize_properties
    attribute :unused_artifacts_cleanup_period_hours
    attribute :url, ""
    attribute :username
    attribute :v3_feed_url
    attribute :vcs_git_download_url
    attribute :vcs_git_provider
    attribute :vcs_type
    attribute :xray_index, false
    attribute :yum_root_depth, 0

    #
    # Creates or updates a repository configuration depending on if the
    # repository configuration previously existed. This method also works
    # around Artifactory's dangerous default behavior:
    #
    #   > An existing repository with the same key are removed from the
    #   > configuration and its content is removed!
    #
    # @return [Boolean]
    #
    def save
      if self.class.find(key, client: client)
        client.post(api_path, to_json, headers)
      else
        client.put(api_path, to_json, headers)
      end
      true
    end

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
        Resource::Artifact.search(name: ".*", repos: key)
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

      response["children"]
    end

    #
    # Delete this repository from artifactory, suppressing any +ResourceNotFound+
    # exceptions might occur.
    #
    # @return [Boolean]
    #   true if the object was deleted successfully, false otherwise
    #
    def delete
      client.delete(api_path)
      true
    rescue Error::HTTPError => e
      false
    end

    #
    # The hash representation
    #
    # @example An example hash response
    #   { 'key' => 'local-repo1', 'includesPattern' => '**/*' }
    #
    # @return [Hash]
    #
    def to_hash
      attributes.keep_if {|x| repository_type_attributes.include?(x) }.inject({}) do |hash, (key, value)|
        unless Resource::Base.has_attribute?(key)
          hash[Util.camelize(key, true)] = send(key.to_sym)
        end

        hash
      end
    end

    private

    #
    # The path to this repository on the server.
    #
    # @return [String]
    #
    def api_path
      "/api/repositories/#{url_safe(key)}"
    end

    #
    # The default headers for this object. This includes the +Content-Type+.
    #
    # @return [Hash]
    #
    def headers
      @headers ||= {
        "Content-Type" => content_type,
      }
    end

    #
    # The default Content-Type for this repository. It varies based on the
    # repository type.
    #
    # @return [String]
    #
    def content_type
      case rclass.to_s.downcase
      when "local"
        "application/vnd.org.jfrog.artifactory.repositories.LocalRepositoryConfiguration+json"
      when "remote"
        "application/vnd.org.jfrog.artifactory.repositories.RemoteRepositoryConfiguration+json"
      when "virtual"
        "application/vnd.org.jfrog.artifactory.repositories.VirtualRepositoryConfiguration+json"
      else
        raise "Unknown Repository type `#{rclass}'!"
      end
    end

    #
    # The default Content-Type for this repository. It varies based on the
    # repository type.
    #
    # @return [Array<Symbol>]
    #
    def repository_type_attributes
      case rclass.to_s.downcase
      when "local"
        %i[archive_browsing_enabled blacked_out block_pushing_schema1 calculate_yum_metadata cdn_redirect checksum_policy_type debian_trivial_layout description docker_api_version download_redirect enable_file_lists_indexing excludes_pattern handle_releases handle_snapshots includes_pattern key key_pair_ref max_unique_snapshots max_unique_tags notes optional_index_compression_formats package_type property_sets rclass repo_layout_ref snapshot_version_behavior suppress_pom_consistency_checks xray_index yum_root_depth]
      when "remote"
        %i[allow_any_host_auth assumed_offline_period_secs blacked_out block_mismatching_mime_types block_pushing_schema1 bower_registry_url bypass_head_requests cdn_redirect client_tls_certificate composer_registry_url content_synchronisation description download_context_path download_redirect enable_cookie_management enable_token_authentication excludes_pattern external_dependencies_enabled external_dependencies_patterns feed_context_path fetch_jars_eagerly fetch_sources_eagerly handle_releases handle_snapshots hard_fail includes_pattern key local_address max_unique_snapshots missed_retrieval_cache_period_secs notes offline package_type password property_sets proxy py_pi_registry_url rclass remote_repo_checksum_policy_type repo_layout_ref retrieval_cache_period_secs share_configuration socket_timeout_millis store_artifacts_locally suppress_pom_consistency_checks synchronize_properties unused_artifacts_cleanup_period_hours url username v3_feed_url vcs_git_download_url vcs_git_provider vcs_type xray_index]
      when "virtual"
        %i[artifactory_requests_can_retrieve_remote_artifacts debian_trivial_layout default_deployment_repo description excludes_pattern external_dependencies_enabled external_dependencies_patterns external_dependencies_remote_repo includes_pattern key key_pair key_pair_ref notes package_type pom_repository_references_cleanup_policy rclass repo_layout_ref repositories]
      else
        raise "Unknown Repository type `#{rclass}'!"
      end
    end
  end
end
