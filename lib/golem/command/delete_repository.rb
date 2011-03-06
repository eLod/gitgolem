# Command for deleting a repository.
class Golem::Command::DeleteRepository < Golem::Command::Base
    # @private
    USAGE = "name\ndelete a specific repository"

    # Run the command.
    # @param [String] name repository name.
    def run(name)
	repo_path = Golem::Config.repository_path(name)
	abort 'Repository not found!' unless File.directory?(repo_path)
	system("rm -rf #{repo_path}")
	print "Removed repository #{repo_path}\n" if verbose?
    end
end
