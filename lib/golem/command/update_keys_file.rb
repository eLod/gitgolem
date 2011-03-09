# Command for updating the .ssh/authorized_keys file.
class Golem::Command::UpdateKeysFile < Golem::Command::Base
    # @private
    USAGE = "\nupdate authorized_keys file with values from database"
    # Content mark to identify automatically updated part of file.
    CONTENT_MARK = "# golem keys - do not place lines below, because the content gets rewritten (AND DO NOT EDIT THIS LINE!)"
    # Default SSH(D) options to set if using command="" style keys file.
    SSH_OPTS_COMMAND_DEFAULT = "no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-pty"

    # Run the command. Old content is preserved, searched for {CONTENT_MARK}, and only content after the mark gets replaced.
    def run
	orig_content = File.exists?(Golem::Config.keys_file_path) ? File.read(Golem::Config.keys_file_path) : ""
	new_content = if orig_content.match(Regexp.new('^' + Regexp.escape(CONTENT_MARK) + '$'))
	    orig_content.sub(Regexp.new('^' + Regexp.escape(CONTENT_MARK) + '$.*\z', Regexp::MULTILINE), CONTENT_MARK + "\n" + keys_str)
	else
	    orig_content + "\n" + CONTENT_MARK + "\n" + keys_str
	end
	File.open(Golem::Config.keys_file_path, "w") {|f| f.write(new_content)}
    end

    private
	def keys_str
	    Golem::Access.ssh_keys.collect {|user, keys| keys.collect {|key| keys_file_line(user, key)}.join("\n")}.join("\n") + "\n"
	end

	def keys_file_line(user, key)
	    first_part = if Golem::Config.keys_file_use_command
		"command=\"#{Golem::Config.bin_dir + '/golem'} auth '#{user}'\""
	    else
		"environment=\"GOLEM_USER=#{user}\""
	    end
	    ssh_opts = if Golem::Config.keys_file_ssh_opts.nil?
		Golem::Config.keys_file_use_command ? ",#{SSH_OPTS_COMMAND_DEFAULT}" : ""
	    else
		"," + Golem::Config.keys_file_ssh_opts.to_s
	    end
	    "#{first_part}#{ssh_opts} #{key}"
	end
end
