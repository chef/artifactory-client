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
        client.get('/api/repositories')
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
      def find(options = {})
        client = extract_client!(options)
        name   = options[:name]

        result = client.get("/api/repositories/#{url_safe(name)}")
        from_hash(result, client: client)
      rescue Error::NotFound
        nil
      end

      #
      # Create a instance from the given Hash. This method extracts the "safe"
      # information from the hash and adds them to the instance.
      #
      # @example Create a new resource from a hash
      #   Repository.from_hash('downloadUri' => '...', 'size' => '...')
      #
      # @param [Artifactory::Client] client
      #   the client object to make the request with
      # @param [Hash] hash
      #   the hash to create the instance from
      #
      # @return [Resource::Repository]
      #
      def from_hash(hash, options = {})
        client = extract_client!(options)

        new.tap do |instance|
          instance.blacked_out               = hash['blackedOut']
          instance.description               = hash['description']
          instance.checksum_policy           = hash['checksumPolicyType']
          instance.excludes_pattern          = hash['excludesPattern']
          instance.handle_releases           = hash['handleReleases']
          instance.handle_snapshots          = hash['handleSnapshots']
          instance.includes_pattern          = hash['includesPattern']
          instance.key                       = hash['key']
          instance.maximum_unique_snapshots  = hash['maxUniqueSnapshots']
          instance.notes                     = hash['notes']
          instance.property_sets             = hash['propertySets']
          instance.snapshot_version_behavior = hash['snapshotVersionBehavior']
          instance.suppress_pom_checks       = hash['suppressPomConsistencyChecks']
          instance.type                      = hash['rclass']
        end
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
    attribute :snapshot_version_behavior, 'non-unique'
    attribute :suppress_pom_checks, false
    attribute :type

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
    def upload(path_or_io, path, properties = {}, headers = {})
      file = if path_or_io.is_a?(File)
               path_or_io
             else
               File.new(File.expand_path(path_or_io))
             end

      matrix   = to_matrix_properties(properties)
      endpoint = File.join("#{url_safe_key}#{matrix}", path)

      client.put(endpoint, { file: file }, headers)
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
    #
    #
    def upload_from_archive(path_or_io, path, properties = {}, headers = {})
      upload(path_or_io, path, properties,
        'X-Explode-Archive' => true,
      )
    end

    #
    #
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
      response = get("/api/storage/#{url_safe_key}", {
        deep:            0,
        listFolders:     0,
        mdTimestamps:    0,
        includeRootPath: 0,
      })

      response['children']
    end

    private

    #
    #
    #
    def url_safe_key
      @url_safe_key ||= URI.escape(key.to_s)
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
  end
end
