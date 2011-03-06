# Command to save configuration file.
class Golem::Command::SaveConfig < Golem::Command::Base
    # @private
    USAGE = "\nsave the configuration file\nPLEASE NOTE: this may destroy (overwrite) your old config (and thus destroy your static database)"

    # Run the command. Calls {Golem::Config.save!}.
    def run
	Golem::Config.save!
	print "Config was saved to #{Golem::Config.cfg_path.to_s}\n" if verbose?
    end
end
