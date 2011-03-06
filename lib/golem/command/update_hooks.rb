# Command for updating hooks in repositories.
class Golem::Command::UpdateHooks < Golem::Command::Base
    include Golem::Command::ManageHooks
    # @private
    USAGE = "\nupdate hooks in every repository (please note: deletes old hooks and symlinks new ones)"

    # Run the command. It runs {#clear_hooks} and {#install_hooks} on every repository.
    def run
	Golem::Access.repositories.each do |repo|
	    clear_hooks(repo)
	    install_hooks(repo)
	end
    end
end
