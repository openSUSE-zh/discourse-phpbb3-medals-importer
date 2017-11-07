require 'mysql2'
require 'pg'

module MedalsMod
  # return a database connection
  class DB
    def initialize(config)
      @config = ThanksMod::Config.new(config).hash
    end

    def respond_to_missing?(dbtype)
      %i[mysql2 pg].include?(dbtype) || super
    end

    def method_missing(dbtype)
      super unless %i[mysql2 pg].include?(dbtype)
      para = @config[dbtype.to_s]
      if dbtype == :mysql2
        "#{dbtype.to_s.capitalize}::Client".split('::')
                                           .inject(Object) do |o, c|
          o.const_get c
        end.new(para)
      elsif dbtype == :pg
        Object.const_get(dbtype.to_s.upcase).connect(para)
      end
    end
  end
end
