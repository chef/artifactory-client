module Artifactory
  module Util
    extend self

    #
    # Covert the given CaMelCaSeD string to under_score. Graciously borrowed
    # from http://stackoverflow.com/questions/1509915.
    #
    # @param [String] string
    #   the string to use for transformation
    #
    # @return [String]
    #
    def underscore(string)
      string
        .to_s
        .gsub(/::/, '/')
        .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
        .gsub(/([a-z\d])([A-Z])/,'\1_\2')
        .tr('-', '_')
        .downcase
    end

    #
    # Convert an underscored string to it's camelcase equivalent constant.
    #
    # @param [String] string
    #   the string to convert
    #
    # @return [String]
    #
    def camelize(string, lowercase = false)
      result = string
        .to_s
        .split('_')
        .map { |e| e.capitalize }
        .join

      if lowercase
        result[0,1].downcase + result[1..-1]
      else
        result
      end
    end

    #
    # Truncate the given string to a certain number of characters.
    #
    # @param [String] string
    #   the string to truncate
    # @param [Hash] options
    #   the list of options (such as +length+)
    #
    def truncate(string, options = {})
      length = options[:length] || 30

      if string.length > length
        string[0..length-3] + '...'
      else
        string
      end
    end

    #
    # Rename a list of keys to the given map.
    #
    # @example Rename the given keys
    #   rename_keys(hash, foo: :bar, zip: :zap)
    #
    # @param [Hash] options
    #   the options to map
    # @param [Hash] map
    #   the map of keys to map
    #
    # @return [Hash]
    #
    def rename_keys(options, map = {})
      Hash[options.map { |k, v| [map[k] || k, v] }]
    end

    #
    # Slice the given list of options with the given keys.
    #
    # @param [Hash] options
    #   the list of options to slice
    # @param [Array<Object>] keys
    #   the keys to slice
    #
    # @return [Hash]
    #   the sliced hash
    #
    def slice(options, *keys)
      keys.inject({}) do |hash, key|
        hash[key] = options[key] if options[key]
        hash
      end
    end
  end
end
