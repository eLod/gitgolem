require 'optparse'

# Parsing command line options.
module Golem::Parser
    # Parse arguments and run the specified command (or +environment+ if non given).
    def self.run(args)
	options = {}
	::OptionParser.new do |opts|
	    opts.banner = "Usage: golem [options] command [arguments]"
	    opts.separator ""
	    opts.separator "Options:"
	    opts.on("-c", "--config FILE", "path to config file") {|val| options[:cfg_path] = val}
	    opts.on("-d", "--db URL", "database to use (e.g. 'simple' or 'postgres://', etc.)") {|val| options[:db] = val}
	    opts.on("-u", "--user-home PATH", "path to user's home (e.g. the authorized key will be written here)") {|val| options[:user_home] = val}
	    opts.on("-r", "--repositories DIR", "path to repositories (may be relative to user_home)") {|val| options[:repository_dir] = val}
	    opts.on("-b", "--base DIR", "path to base (place of conf, hooks by default)") {|val| options[:base_dir] = val}
	    opts.on("-B", "--bin DIR", "path to executable (defaults to base/bin)") {|val| options[:bin_dir] = val}
	    opts.on("-H", "--hooks DIR", "path to hooks (defaults to base/hooks)") {|val| options[:hooks_dir] = val}
	    opts.on("-h", "--help", "show this message") {puts opts; exit}
	    opts.on("-v", "--verbose", "show output (defaults to false, note: not every command supports it)") {Golem::Parser.verbose = true}
	    opts.separator ""
	    opts.separator "Environment variables (options always take precedence):"
	    opts.separator "\tGOLEM_CONF is used as config file path if exists"
	    opts.separator "\tGOLEM_BASE is used as base dir"
	    opts.separator "\tHOME is used as user-home path"
	    opts.separator ""
	    opts.separator "Commands:"
	    Golem::Command::COMMANDS.each do |cmd|
		usage = Golem::Command.usage(cmd).split("\n")
		opts.separator "\tgolem #{cmd.to_s} " + usage.shift
		opts.separator usage.collect {|l| "\t\t" + l}.join("\n") if usage.length > 0
		opts.separator "\t\tsynonyms: " + Golem::Command::ALIASES[cmd].join(', ') if Golem::Command::ALIASES.key?(cmd)
	    end
	end.parse! args
	Golem::Config.auto_configure(options.delete(:cfg_path)) do
	    options.each do |key, val|
		send((key.to_s + "=").to_sym, val)
	    end
	end
	Golem::Command.run(args.shift || "environment", {:verbose => (@verbose || false)}, *args)
    end

    # @private
    def self.verbose=(val) # :nodoc:
	@verbose = !!val
    end
end
