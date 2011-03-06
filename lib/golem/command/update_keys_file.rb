# Command for updating the .ssh/authorized_keys file.
class Golem::Command::UpdateKeysFile < Golem::Command::Base
    # @private
    USAGE = "\nupdate authorized_keys file with values from database"
    # Content mark to identify automatically updated part of file.
    CONTENT_MARK = "# golem keys - do not place lines below, because the content gets rewritten (AND DO NOT EDIT THIS LINE!)"
    # SSH(D) options to set.
    SSH_OPTS = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty"

    # Run the command. Old content is preserved, searched for {CONTENT_MARK}, and only content after the mark gets replaced.
    def run
	auth_cmd = Golem::Config.bin_dir + "/golem-auth"
	keys_str = Golem::Access.ssh_keys.collect {|user, keys| keys.collect {|key| "command=\"#{auth_cmd} #{user}\",#{SSH_OPTS} #{key}"}.join("\n")}.join("\n") + "\n"
	orig_content = File.exists?(Golem::Config.keys_file_path) ? File.read(Golem::Config.keys_file_path) : ""
	new_content = if orig_content.match(Regexp.new('^' + Regexp.escape(CONTENT_MARK) + '$'))
	    orig_content.sub(Regexp.new('^' + Regexp.escape(CONTENT_MARK) + '$.*\z', Regexp::MULTILINE), CONTENT_MARK + "\n" + keys_str)
	else
	    orig_content + "\n" + CONTENT_MARK + "\n" + keys_str
	end
	File.open(Golem::Config.keys_file_path, "w") {|f| f.write(new_content)}
    end
end
