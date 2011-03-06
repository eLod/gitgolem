# Golem provides an easy way to host and manage access to git repositories on a server under a single user. More details can be found:
# * for configuration at {Golem::Config},
# * for database handling at {Golem::DB},
# * for access control at {Golem::Access},
# * for commands at {Golem::Command},
# * for general help at {file:README}.
module Golem
    autoload :Access, "golem/access"
    autoload :Command, "golem/command"
    autoload :Config, "golem/config"
    autoload :DB, "golem/db"
    autoload :Parser, "golem/parser"
    autoload :Version, "golem/version"

    # Configure Golem.
    # @see Golem::Config.configure
    def self.configure(opts_or_path = nil, &block)
	Config.configure(opts_or_path, &block)
	self
    end
end
