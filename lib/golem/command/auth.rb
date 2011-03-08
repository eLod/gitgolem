# Command for authorization. Checks authenticated (via sshd) user's access to given repository, if access granted creates repository if needed and calls git-shell.
class Golem::Command::Auth < Golem::Command::Base
    # @private
    USAGE = "user (defaults to GOLEM_USER env)\nused for authorizing users, called by sshd (via keys file), calls git-shell"
    # Regexp to check for git commands.
    RE_CMD = /\A\s*(git[ \-](upload-pack|upload-archive|receive-pack))\s+'([^.]+).git'/

    # Run the command. Git command is read from ENV['SSH_ORIGINAL_COMMAND']. Set environment variables (for hooks) and call git-shell if access granted.
    # @param [String] user the user to run as.
    def run(user = ENV['GOLEM_USER'])
	abort 'Please use git!' unless matches = (ENV['SSH_ORIGINAL_COMMAND'] || '').match(RE_CMD)
	cmd, subcmd, repo = matches[1, 3]
	abort 'You don\'t have permission!' unless Golem::Access.check(user, repo, subcmd)
	command(:create_repository, repo) unless File.directory?(Golem::Config.repository_path(repo))
	set_env(user, repo)
	exec "git-shell", "-c", "#{cmd} '#{ENV['GOLEM_REPOSITORY_PATH']}'"
    end

    private
	def set_env(user, repo)
	    {
		'GOLEM_USER' => user,
		'GOLEM_REPOSITORY_NAME' => repo,
		'GOLEM_REPOSITORY_PATH' => Golem::Config.repository_path(repo),
	    }.each {|k, v| ENV[k] = v}
	end
end
