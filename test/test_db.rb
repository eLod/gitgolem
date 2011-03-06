require 'helper'

class TestDb < WithTestDb
    def test_static
	assert_equal users.collect {|u| {:name => u}}, Golem::DB.users
	assert_equal users, Golem::DB.users(:return => :array)
	assert_equal repos.collect {|u, r| (r.is_a?(Array) ? r : [r]).collect {|r| {:user_name => u, :name => r}}}.flatten, Golem::DB.repositories
	assert_equal repos.values.flatten, Golem::DB.repositories(:return => :array)
	assert_equal keys.collect {|u, k| (k.is_a?(Array) ? k : [k]).collect {|k| {:user_name => u, :key => k}}}.flatten, Golem::DB.ssh_keys
	assert_equal keys.collect {|u, k| (k.is_a?(Array) ? k : [k]).collect {|k| [u, k]}}.flatten(1), Golem::DB.ssh_keys(:return => :array)
    end
end
