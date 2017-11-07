require 'yaml'

module MedalsMod
  # Parse yaml config
  class Config
    attr_reader :hash
    def initialize(conf)
      path = File.expand_path(File.dirname(__FILE__)) + '/../../config/'
      file = path + conf + '.yml'
      raise 'no such config' unless File.exist?(file)
      @hash = YAML.safe_load(open(file, 'r:UTF-8').read)
    end
  end
end
