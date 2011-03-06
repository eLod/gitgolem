# Static database for small installations. To use it, write:
#  Golem.configure do |cfg|
#    cfg.db = 'static'
#    Golem::DB.setup do |db|
#      db.add_user 'test_user'
#      db.add_repository 'test_repository', 'test_user'
#      db.add_key 'test_user', 'test_key'
#    end
#  end
class Golem::DB::Static
    # Create database, initialize users, repositories and ssh_keys to [].
    def initialize
	@users, @repositories, @ssh_keys = [], [], []
    end

    # Retrieve users.
    # @param [Hash] opts options, see {Golem::DB}.
    # @return [Array] list of users.
    def users(opts = {})
	opts[:return] == :array ? @users.collect {|u| u[:name]} : @users
    end

    # Retrieve repositories.
    # @param [Hash] opts options, see {Golem::DB}.
    # @return [Array] list of repotitories.
    def repositories(opts = {})
	opts[:return] == :array ? @repositories.collect {|r| r[:name]} : @repositories
    end

    # Retrieve ssh keys.
    # @param [Hash] opts options, see {Golem::DB}.
    # @return [Array] list of keys.
    def ssh_keys(opts = {})
	opts[:return] == :array ? @ssh_keys.collect {|k| [k[:user_name], k[:key]]} : @ssh_keys
    end

    # Add user to database.
    # @param [String] name username,
    # @return [Array] list of users.
    def add_user(name)
	@users << {:name => name}
    end

    # Add repository to database.
    # @param [String] name repository name,
    # @param [String] user_name username.
    # @return [Array] list of repositories.
    def add_repository(name, user_name)
	abort "Cannot add repository, user not found!" unless users(:return => :array).include?(user_name)
	@repositories << {:name => name, :user_name => user_name}
    end

    # Add key to database.
    # @param [String] user_name username,
    # @param [String] key ssh key (e.g. +cat id_rsa.pub+).
    # @return [Array] list of keys.
    def add_key(user_name, key)
	abort "Cannot add key, user not found!" unless users(:return => :array).include?(user_name)
	@ssh_keys << {:user_name => user_name, :key => key}
    end

    # Setup database.
    def setup(&block)
	yield self
    end
end
