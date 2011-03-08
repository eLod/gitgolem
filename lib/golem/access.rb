# Access control, implements basic control, may be overriden (see {check}).
module Golem::Access
    # Main access control, checks if user is the owner of the repository. When overriden +gitcmd+ may be used to determine R/W access.
    # @param [String] user username,
    # @param [String] repo repository name,
    # @param [String] gitcmd git command (one of +upload-pack+, +upload-archive+, +receive-pack+).
    # @return [Boolean] result.
    def self.check(user, repo, gitcmd)
	Golem::DB.repositories(:user_name => user, :name => repo, :fields => :name).length > 0
    end

    # @return [Array] list of usernames.
    def self.users
	Golem::DB.users(:fields => :name, :return => :array)
    end

    # @return [Hash] username => [array of keystrings] pairs.
    def self.ssh_keys
	Golem::DB.ssh_keys(:fields => [:name, :key], :return => :array).inject({}) do |memo, (user, key)|
	    if memo.key?(user)
		memo[user] << key
	    else
		memo[user] = [key]
	    end
	    memo
	end
    end

    # @return [Array] list of repository names.
    def self.repositories
	Golem::DB.repositories(:fields => :name, :return => :array)
    end

    # Convenience method to check if requested access type is read (e.g. command was +receive-pack+).
    # @return [Boolean] if read access was requested.
    def self.read?(gitcmd)
	gitcmd == "receive-pack"
    end

    # Convenience method to check if requested access type is write (e.g. command was +upload-pack+ or +upload-archive+).
    # @return [Boolean] if write access was requested.
    def self.write?(gitcmd)
	!!gitcmd.match(/\Aupload-(pack|archive)\z/)
    end
end
