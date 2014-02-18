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
        client.get('/api/repositories').map do |hash|
          find(hash['key'], client: client)
        end.compact
      end

      #
      # Find (fetch) a repository by name.
      #
      # @example Find a respository by named key
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

    attribute :blacked_out, false
    attribute :description
    attribute :checksum_policy, 'client-checksums'
    attribute :excludes_pattern, ''
    attribute :handle_releases, true
    attribute :handle_snapshots, true
    attribute :includes_pattern, '**/*'
    attribute :key, ->{ raise 'Key is missing!' }
    attribute :maximum_unique_snapshots, 0
    attribute :notes
    attribute :property_sets, []
    attribute :repo_layout_ref, 'maven-2-default'
    attribute :rclass, 'local'
    attribute :snapshot_version_behavior, 'non-unique'
    attribute :suppress_pom_checks, false

    def save
      client.put(api_path, to_json, headers)
      true
    end

    #
    # Upload an artifact into the repository. If the first parameter is a File
    # object, that file descriptor is passed to the uploader. If the first
    # parameter is a string, it is assumed to be the path to a local file on
    # disk. This method will automatically construct the File object from the
    # given path.
    #
    # @see bit.ly/1dhJRMO Artifactory Matrix Properties
    #
    # @example Upload an artifact from a File instance
    #   file = File.new('/local/path/to/file.deb')
    #   repo = Repository.new('libs-release-local')
    #   repo.upload(file, 'file.deb')
    #
    # @example Upload an artifact from a path
    #   repo = Repository.new('libs-release-local')
    #   repo.upload('/local/path/to/file.deb', 'file.deb')
    #
    # @example Upload an artifact with matrix properties
    #   repo = Repository.new('libs-release-local')
    #   repo.upload('/local/path/to/file.deb', 'file.deb', {
    #     status: 'DEV',
    #     rating: 5,
    #     branch: 'master'
    #   })
    #
    # @param [String, File] path_or_io
    #   the file or path to the file to upload
    # @param [String] path
    #   the path where this resource will live in the remote artifactory
    #   repository, relative to the current repo
    # @param [Hash] headers
    #   the list of headers to send with the request
    # @param [Hash] properties
    #   a list of matrix properties
    #
    # @return [Resource::Artifact]
    #
    def upload(path_or_io, path, properties = {}, headers = {})
      file = if path_or_io.is_a?(File)
               path_or_io
             else
               File.new(File.expand_path(path_or_io))
             end

      matrix   = to_matrix_properties(properties)
      endpoint = File.join("#{url_safe(key)}#{matrix}", path)

      response = client.put(endpoint, { file: file }, headers)
      Resource::Artifact.from_hash(response)
    end

    #
    # Upload an artifact with the given SHA checksum. Consult the artifactory
    # documentation for the possible responses when the checksums fail to
    # match.
    #
    # @see Repository#upload More syntax examples
    #
    # @example Upload an artifact with a checksum
    #   repo = Repository.new('libs-release-local')
    #   repo.upload_with_checksum('/local/file', '/remote/path', 'ABCD1234')
    #
    # @param (see Repository#upload)
    # @param [String] checksum
    #   the SHA1 checksum of the artifact to upload
    #
    def upload_with_checksum(path_or_io, path, checksum, properties = {})
      upload(path_or_io, path, properties,
        'X-Checksum-Deploy' => true,
        'X-Checksum-Sha1'   => checksum,
      )
    end

    #
    # Upload an artifact with the given archive. Consult the artifactory
    # documentation for the format of the archive to upload.
    #
    # @see Repository#upload More syntax examples
    #
    # @example Upload an artifact with a checksum
    #   repo = Repositor.new('libs-release-local')
    #   repo.upload_from_archive('/local/archive', '/remote/path')#
    #
    # @param (see Repository#upload)
    #
    def upload_from_archive(path_or_io, path, properties = {})
      upload(path_or_io, path, properties,
        'X-Explode-Archive' => true,
      )
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
    # @todo Make this a mixin or reusable?
    #
    def to_matrix_properties(hash = {})
      properties = hash.map do |k, v|
        key   = URI.escape(k.to_s)
        value = URI.escape(v.to_s)

        "#{key}=#{value}"
      end

      if properties.empty?
        nil
      else
        ";#{properties.join(';')}"
      end
    end

    #
    # The default headers for this object. This includes the +Content-Type+.
    #
    # @return [Hash]
    #
    def headers
      @headers ||= {
        'Content-Type' => content_type
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
