# Database handling. See {Golem::DB::Pg} and {Golem::DB::Static}.
#
# A +db+ should respond to 4 methods: +users+, +repositories+, +ssh_keys+, +setup+.
# The first 3 should take a single hash argument (options) and return an array/hash of results, +setup+
# takes no arguments (it may use a block). These options should be supported:
# * +:fields+: list of fields the results should include,
# * +:return+: type of return value, if is +:array+ then results should be an array, hash (attribute name => value pairs) otherwise,
# * any other key: should be interpreted as conditions (e.g. <i>:user => "name"</i> should return objects whose +user+ attribute is _name_).
module Golem::DB
    autoload :Pg, "golem/db/pg"
    autoload :Static, "golem/db/static"

    # Proxy for the used db.
    # @return [Pg, Static] the db currently used.
    def self.db
	@db ||= case Golem::Config.db
	    when /\Apostgres:\/\// then Pg.new(Golem::Config.db)
	    when "static" then Static.new
	    else abort "Unknown DB (#{Golem::Config.db.to_s})."
	    end
    end

    # Forwards to proxy's users.
    # @return [Array, Hash] results.
    def self.users(opts = {})
	db.users(opts)
    end

    # Forwards to proxy's repositories.
    # @return [Array, Hash] results.
    def self.repositories(opts = {})
	db.repositories(opts)
    end

    # Forwards to proxy's ssh_keys.
    # @return [Array, Hash] results.
    def self.ssh_keys(opts = {})
	db.ssh_keys(opts)
    end

    # Forwards to proxy's setup.
    # @return [] depends on proxy.
    def self.setup(&block)
	db.setup(&block)
    end
end
