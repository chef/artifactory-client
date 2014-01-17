require 'artifactory/version'

module Artifactory
  #
  # A value that represents an unset value.
  #
  # @return [Object]
  #
  UNSET_VALUE = Object.new

  autoload :Connection, 'artifactory/connection'
  autoload :Error,      'artifactory/errors'
  autoload :Util,       'artifactory/util'

  module Resource
    autoload :Artifact,   'artifactory/resources/artifact'
    autoload :Base,       'artifactory/resources/base'
    autoload :Build,      'artifactory/resources/build'
    autoload :Plugin,     'artifactory/resources/plugin'
    autoload :Repository, 'artifactory/resources/repository'
    autoload :System,     'artifactory/resources/system'
  end

  class << self
    def root
      @root ||= Pathname.new(File.expand_path('../../', __FILE__))
    end

    def connection
      @connection ||= Artifactory::Connection.new(
        url: 'http://localhost:8081/artifactory',
        auth: {
          username: 'admin',
          password: 'password'
        }
      )
    end
  end
end

require 'i18n'
I18n.enforce_available_locales = false
I18n.load_path << Dir[Artifactory.root.join('locales', '*.yml').to_s]
