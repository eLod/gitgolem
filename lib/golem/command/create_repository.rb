# Command for creating a repository.
class Golem::Command::CreateRepository < Golem::Command::Base
    include Golem::Command::ManageHooks
    # @private
    USAGE = "name\ncreate a repository and install hooks"

    # Run the command. Installs hooks with {#install_hooks}.
    # @param [String] name repository name.
    def run(name)
	path = Golem::Config.repository_path(name)
	abort "Repository already exists!" if File.directory?(path)
	pwd = Dir.pwd
	Dir.mkdir(path, 0700)
	Dir.chdir(path)
	system('git --bare init >&2')
	print "Repository #{path} created, installing hooks...\n" if verbose?
	install_hooks(name)
	Dir.chdir(pwd)
    end
end
