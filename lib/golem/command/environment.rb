# Command for listing configuration variables.
class Golem::Command::Environment < Golem::Command::Base
    # @private
    USAGE = "\nlist configuration values"

    # List configuration variables that are set.
    def run
	print "Configuration values:\n"
	print Golem::Config.config_hash.collect {|k, v| "\t " + k.to_s + ": " + v.to_s}.join("\n") + "\n"
    end
end
