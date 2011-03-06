# Command for clearing repositories, suitable for cron.
class Golem::Command::ClearRepositories < Golem::Command::Base
    # @private
    USAGE = "\nclear .git directories not found in database"

    # Run the command. Removes every '*.git' directory in {Golem::Config.repository_base_path}
    # unless {Golem::Access.repositories} includes repository. Calls {Golem::Command::DeleteRepository}.
    def run
	repos = Golem::Access.repositories
	Dir.glob(Golem::Config.repository_base_path + '/*.git').each do |repo_path|
	    repo = File.basename(repo_path)[0..-5]
	    next if repos.include?(repo)
	    command :delete_repository, repo
	end
    end
end
