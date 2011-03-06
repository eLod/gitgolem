require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'

$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'golem'

class Test::Unit::TestCase
    class << self; attr_accessor :cfg, :users, :repos, :keys end
    attr_accessor :cfg, :users, :repos, :keys

    def setup
	self.cfg = self.class.cfg || {}
	self.users = self.class.users || []
	self.repos = self.class.repos || {}
	self.keys = self.class.keys || {}
	Golem.configure(cfg) do |cfg|
	    cfg.db = 'static'
	    Golem::DB.setup do |db|
		users.each {|u| db.add_user u}
		repos.each {|u, r| (r.is_a?(Array) ? r : [r]).each {|r| db.add_repository r, u}}
		keys.each {|u, k| (k.is_a?(Array) ? k : [k]).each {|k| db.add_key u, k}}
	    end
	end if users.length > 0
    end

    def teardown
	Golem::Config.instance_variable_set("@vars", nil) #need to reset
	Golem::DB.instance_variable_set("@db", nil) #need to reset
    end
end

class WithTestDb < Test::Unit::TestCase
    self.users = ["test_user1", "test_user2"]
    self.repos = {"test_user1" => ["test_repo1", "test_repo2"], "test_user2" => "test_repo3"}
    self.keys = {"test_user1" => ["test_key1", "test_key2"], "test_user2" => "test_key3"}
    undef_method :default_test

    def self.inherited(base)
	base.users = users
	base.repos = repos
	base.keys = keys
    end
end

