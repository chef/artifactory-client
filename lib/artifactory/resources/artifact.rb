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
    # @see {Artifact#copy_or_move_to}
    #
    def copy_to(options = {})
      copy_or_move_to(:copy, options)
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
    # @see {Artifact#copy_or_move_to}
    #
    def move_to(options = {})
      copy_or_move_to(:move, options)
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
    # Download the artifact onto the local disk. If the local path already
    # exists on the object, it will be used; othwerise, +:to+ is a required
    # option. If the remote_path already exists on the object, it is used;
    # otherwise +:from+ is a required option.
    #
    # @example Download a remote artifact locally
    #   artifact.download(to: '~/Desktop/artifact.deb')
    #
    # @example Download an artifact into a folder
    #   # If a folder is given, the basename of the file is used
    #   artifact.download(to: '~/Desktop') #=> ~/Desktop/artifact.deb
    #
    # @example Download a local artifact from the remote
    #   artifact.download(from: '/libs-release-local/org/acme/artifact.deb')
    #
    # @example Download an artifact with pre-populated fields
    #   artifact.download #=> `to` and `from` are pulled from the object
    #
    # @param [Hash] options
    # @option options [String] to
    #   the path to download the artifact to disk
    # @option options [String] from
    #   the remote path on artifactory to download the artifact from
    #
    # @return [String]
    #   the path where the file was downloaded on disk
    #
    def download(options = {})
      options[:to]   ||= local_path
      options[:from] ||= download_path

      destination = File.expand_path(options[:to])

      # If they gave us a folder, use the object's filename
      if File.directory?(destination)
        destination = File.join(destination, File.basename(options[:from]))
      end

      File.open(destination, 'wb') do |file|
        file.write(_get(options[:from]).body)
      end

      destination
    end

    private

    #
    # Copy or move current artifact to a new destination.
    #
    # @example Move the current artifact to +ext-releases-local+
    #   artifact.move(to: '/ext-releaes-local/org/acme')
    # @example Copy the current artifact to +ext-releases-local+
    #   artifact.move(to: '/ext-releaes-local/org/acme')
    #
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
    def copy_or_move_to(action, options = {})
      params = {}.tap do |param|
        param[:failFast]        = 1 if options[:fail_fast]
        param[:suppressLayouts] = 1 if options[:suppress_layouts]
        param[:dry]             = 1 if options[:dry_run]
        param[:to]              = options[:to] || raise(':to option missing!')
      end

      # /artifactory/api/storage/libs-release-local/org/acme/artifact.deb #=> libs-release-local/org/acme/artifact.deb
      path = api_path.split('/api/storage/', 2).last

      # Okay, seriously, WTF Artifactory? Are you fucking serious? You want me
      # to make a POST request, but you don't actually read the contents of the
      # POST request, you read the URL-params. Sigh, whoever claimed this was a
      # RESTful API should seriously consider a new occupation.
      params = params.map do |k, v|
        key   = URI.escape(k.to_s)
        value = URI.escape(v.to_s)

        "#{key}=#{value}"
      end

      endpoint = File.join('api', action.to_s, path.to_s) + '?' + params.join('&')

      _post(endpoint).json
    end
  end
end
