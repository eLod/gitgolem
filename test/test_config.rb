require 'helper'

class TestConfig < Test::Unit::TestCase
    def test_configure
	assert_nothing_raised do
	    Golem.configure do |cfg|
		Golem::Config::CFG_VARS.each do |var|
		    cfg.send((var.to_s + "=").to_sym, var)
		end
	    end
	    Golem::Config::CFG_VARS.each do |var|
		assert_equal var, Golem::Config.send(var)
	    end
	end
    end
end
