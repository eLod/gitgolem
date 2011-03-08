# Command to setup the database schema (only useful for {Golem::DB::Pg}).
class Golem::Command::SetupDb < Golem::Command::Base
    # @private
    USAGE = "\nsetup database schema\nPLEASE NOTE: this is useful for postgres database only"

    # Run the command. Calls {Golem::DB.setup}.
    def run
	Golem::DB.setup
	print "Database schema is set up at #{Golem::Config.db.to_s}\n" if verbose?
    end
end
