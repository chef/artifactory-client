module Artifactory
  class Resource::Artifact < Resource::Base
    class << self
      def search(name, options = {})
        query = {}.tap do |h|
          h[:name]  = name || '.*'
          h[:repos] = Array(options[:repos]).join(',') if options[:repos]
        end

        _get('/api/search/artifact', query).json['results'].map do |artifact|
          from_url(artifact['uri'])
        end
      end

      def from_url(url)
        from_hash(_get(url).json)
      end

      def from_hash(hash)
        new.tap do |instance|
          instance.api_path      = hash['uri']
          instance.md5           = hash['checksums']['md5']
          instance.sha1          = hash['checksums']['sha1']
          instance.created       = Time.parse(hash['created'])
          instance.download_path = hash['downloadUri']
          instance.last_modified = Time.parse(hash['lastModified'])
          instance.last_updated  = Time.parse(hash['lastUpdated'])
          instance.mime_type     = hash['mimeType']
          instance.size          = hash['size']
        end
      end
    end

    attribute :api_path, ->{ raise 'API path missing!' }
    attribute :created
    attribute :download_path, ->{ raise 'Remote path missing!' }
    attribute :last_modified
    attribute :last_updated
    attribute :local_path, ->{ raise 'Local destination missing!' }
    attribute :mime_type
    attribute :md5
    attribute :sha1
    attribute :size

    #
    #
    #
    def initialize

    end

    #
    # @see {Artifact#copy_or_move}
    #
    def copy(destination, options = {})
      copy_or_move(:copy, destination, options)
    end

    #
    # Delete this artifact from repository, suppressing any +ResourceNotFound+
    # exceptions might occur.
    #
    # @return [Boolean]
    #   true if the object was deleted successfully, false otherwise
    #
    def delete
      _delete(download_path).body
    rescue Error::NotFound
      false
    end

    #
    # @see {Artifact#copy_or_move}
    #
    def move(destination, options = {})
      copy_or_move(:move, destination, options)
    end

    #
    # The list of properties for this object.
    #
    # @example List all properties for an artifact
    #   artifact.properties #=> { 'artifactory.licenses'=>['Apache-2.0'] }
    #
    # @return [Hash<String, Object>]
    #   the list of properties
    #
    def properties
      @properties ||= _get(api_path, properties: nil).json['properties']
    end

    #
    # Get compliance info for a given artifact path. The result includes
    # license and vulnerabilities, if any.
    #
    # **This requires the Black Duck addon to be enabled!**
    #
    # @example Get compliance info for an artifact
    #   artifact.compliance #=> { 'licenses' => [{ 'name' => 'LGPL v3' }] }
    #
    # @return [Hash<String, Array<Hash>>]
    #
    def compliance
      @compliance ||= _get(File.join('api/compliance', relative_path)).json
    end

    #
    # Download the artifact onto the local disk.
    #
    # @example Download an artifact
    #   artifact.download #=> /tmp/cache/000adad0-bac/artifact.deb
    #
    # @example Download a remote artifact into a specific target
    #   artifact.download('~/Desktop') #=> ~/Desktop/artifact.deb
    #
    # @param [String] target
    #   the target directory where the artifact should be downloaded to
    #   (defaults to a temporary directory). **It is the user's responsibility
    #   to cleanup the temporary directory when finished!**
    # @param [Hash] options
    # @option options [String] filename
    #   the name of the file when downloaded to disk (defaults to the basename
    #   of the file on the server)
    #
    # @return [String]
    #   the path where the file was downloaded on disk
    #
    def download(target = Dir.mktmpdir, options = {})
      target = File.expand_path(target)

      # Make the directory if it doesn't yet exist
      FileUtils.mkdir_p(target) unless File.exists?(target)

      # Use the server artifact's filename if one wasn't given
      filename = options[:filename] || File.basename(download_path)

      # Construct the full path for the file
      destination = File.join(targer, filename)

      File.open(File.join(destination, filename), 'wb') do |file|
        file.write(_get(download_path).body)
      end

      destination
    end

    private

    #
    # Helper method for extracting the relative (repo) path, since it's not
    # returned as part of the API.
    #
    # @example Get the relative URI from the resource
    #   /libs-release-local/org/acme/artifact.deb
    #
    # @return [String]
    #
    def relative_path
      @relative_path ||= api_path.split('/api/storage', 2).last
    end

    #
    # Copy or move current artifact to a new destination.
    #
    # @example Move the current artifact to +ext-releases-local+
    #   artifact.move(to: '/ext-releaes-local/org/acme')
    # @example Copy the current artifact to +ext-releases-local+
    #   artifact.move(to: '/ext-releaes-local/org/acme')
    #
    # @param [Symbol] action
    #   the action (+:move+ or +:copy+)
    # @param [String] destination
    #   the server-side destination to move or copy the artifact
    # @param [Hash] options
    #   the list of options to pass
    #
    # @option options [Boolean] :fail_fast (default: +false+)
    #   fail on the first failure
    # @option options [Boolean] :suppress_layouts (default: +false+)
    #   suppress cross-layout module path translation during copying or moving
    # @option options [Boolean] :dry_run (default: +false+)
    #   pretend to do the copy or move
    #
    # @return [Hash]
    #   the parsed JSON response from the server
    #
    def copy_or_move(action, destination, options = {})
      params = {}.tap do |param|
        param[:to]              = destination
        param[:failFast]        = 1 if options[:fail_fast]
        param[:suppressLayouts] = 1 if options[:suppress_layouts]
        param[:dry]             = 1 if options[:dry_run]
      end

      # Okay, seriously, WTF Artifactory? Are you fucking serious? You want me
      # to make a POST request, but you don't actually read the contents of the
      # POST request, you read the URL-params. Sigh, whoever claimed this was a
      # RESTful API should seriously consider a new occupation.
      params = params.map do |k, v|
        key   = URI.escape(k.to_s)
        value = URI.escape(v.to_s)

        "#{key}=#{value}"
      end

      endpoint = File.join('api', action.to_s, relative_path) + '?' + params.join('&')

      _post(endpoint).json
    end
  end
end
