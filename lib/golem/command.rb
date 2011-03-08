# Namespace for commands.
module Golem::Command
    # List of command names as symbols.
    COMMANDS = [:auth, :clear_repositories, :create_repository, :delete_repository, :environment, :save_config, :setup_db, :update_hooks, :update_keys_file]
    # Hash of aliases.
    ALIASES = {
	:clear_repositories => ["clear-repositories", "clear-repos", "clear_repos"],
	:create_repository => ["create-repository", "create-repo", "create_repo"],
	:delete_repository => ["delete-repository", "delete-repo", "delete_repo"],
	:environment => ["env"],
	:save_config => ["save-config", "save"],
	:setup_db => ["setup-db", "setup"],
	:update_hooks => ["update-hooks"],
	:update_keys_file => ["update-keys-file", "update-keys", "update_keys"],
    }

    autoload :Auth, "golem/command/auth"
    autoload :ClearRepositories, "golem/command/clear_repositories"
    autoload :CreateRepository, "golem/command/create_repository"
    autoload :DeleteRepository, "golem/command/delete_repository"
    autoload :Environment, "golem/command/environment"
    autoload :SaveConfig, "golem/command/save_config"
    autoload :SetupDb, "golem/command/setup_db"
    autoload :UpdateHooks, "golem/command/update_hooks"
    autoload :UpdateKeysFile, "golem/command/update_keys_file"

    # Run a command.
    # @param [Symbol, String] cmd command name to run,
    # @param [Hash] opts options, see {Base#initialize},
    # @param *args arguments for the command.
    def self.run(cmd, opts = {:verbose => true}, *args)
	find(cmd).new(opts).run(*args)
    end

    # Get command usage to display in help message.
    # @param [Symbol, String] cmd command name.
    # @return [String] usage text or empty string.
    def self.usage(cmd)
	cmd = find(cmd)
	cmd.const_defined?(:USAGE) ? cmd::USAGE : ""
    end

    # Find command class by name.
    # @raise [NameError] if class (constant) not found.
    # @param [Symbol, String] cmd command name to search for.
    # @return [Class] command class.
    def self.find(cmd)
	cmd = ALIASES.find {|key, a| a.include?(cmd.to_s)}.first if ALIASES.any? {|key, aliases| aliases.include?(cmd.to_s)}
	abort "Command not understood." unless COMMANDS.include?(cmd.to_sym)
	const_get cmd.to_s.split("_").collect {|p| p.capitalize}.join.to_sym
    end

    # Abstract class for commands.
    # @abstract Subclass and override {#run} to implement a custom Command class.
    class Base
	# @param [Hash] opts options
	# @option opts [Boolean] :verbose control verbosity.
	def initialize(opts)
	    @opts = opts
	end

	# Check verbosity.
	def verbose?
	    !!@opts[:verbose]
	end

	# Run the command.
	def run
	    abort "Bad command."
	end

	# Run another command.
	# @param [Symbol] cmd the command to run,
	# @param *args arguments for the command.
	def command(cmd, *args)
	    Golem::Command.run(cmd, @opts, *args)
	end
    end

    # Mixin for hook management.
    module ManageHooks
	# Install hooks into repository.
	# @param [String] repo repository name.
	def install_hooks(repo)
	    path = Golem::Config.repository_path(repo)
	    Dir.entries(Golem::Config.hooks_dir).each do |hook|
		hook_src = Golem::Config.hook_path(hook)
		next unless File.file?(hook_src) && File.stat(hook_src).executable? && hook[0..0] != "."
		File.symlink(hook_src, path + '/hooks/' + hook)
		print "Hook installed from #{hook_src} to #{path}/hooks/#{hook}.\n" if verbose?
	    end if File.directory?(Golem::Config.hooks_dir)
	end

	# Remove hooks from repository (please note: this *deletes* old hooks).
	# @param [String] repo repository name.
	def clear_hooks(repo)
	    path = Golem::Config.repository_path(repo)
	    Dir.entries(path + "/hooks").each do |hook|
		hook_src = path + "/hooks/" + hook
		File.delete(hook_src) if File.symlink?(hook_src) && ! File.file?(hook_src)
		next unless File.file?(hook_src) && File.stat(hook_src).executable? && hook[0..0] != "."
		File.delete(hook_src)
		print "Hook removed from #{hook_src}.\n" if verbose?
	    end
	end
    end
end
