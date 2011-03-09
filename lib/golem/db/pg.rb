require 'pg'

# Postgres functionality. Requires +pg+.
class Golem::DB::Pg
    # Initializes +PGConn+ connection.
    # @param [String] db_url postgres url to connect to (e.g. +postgres://user:pw@host/db+).
    def initialize(db_url)
	@connection ||= ::PGconn.connect(*(db_url.match(/\Apostgres:\/\/([^:]+):([^@]+)@([^\/]+)\/(.+)\z/) {|m| [m[3], 5432, nil, nil, m[4], m[1], m[2]]}))
    end

    # Retrieve users.
    # @param [Hash] opts options, see {Golem::DB}.
    # @return [Array] list of users.
    def users(opts = {})
	opts[:table] = :users
	get(opts)
    end

    # Retrieve repositories.
    # @param [Hash] opts options, see {Golem::DB}.
    # @return [Array] list of repotitories.
    def repositories(opts = {})
	opts[:table] = :repositories
	get(opts)
    end

    # Retrieve ssh keys.
    # @param [Hash] opts options, see {Golem::DB}.
    # @return [Array] list of keys.
    def ssh_keys(opts = {})
	opts[:table] = "keys join users on keys.user_name=users.name"
	get(opts)
    end

    # Setup schema.
    # @return [PGRes] result.
    def setup
	@connection.exec(File.read(File.expand(File.dirname(__FILE__) + '/postgres.sql')))
    end

    private
	def get(opts = {})
	    table = opts.delete(:table) || ''
	    fields = opts.delete(:fields) || ['*']
	    fields = [fields] unless fields.is_a?(Array)
	    order = opts.delete(:order)
	    limit = opts.delete(:limit)
	    ret_array = opts.delete(:return) == :array
	    sql = "SELECT #{fields.collect {|f| f.to_s}.join(', ')} FROM #{table.to_s}"
	    sql += " WHERE #{opts.keys.enum_for(:each_with_index).collect {|k, i| k.to_s + ' = $' + (i + 1).to_s}.join(' AND ')}" if opts.length > 0
	    sql += " ORDER BY #{order.to_s}" if order
	    sql += " LIMIT #{limit.to_s}" if limit
	    res = @connection.exec(sql, opts.values)
	    ret_fields = fields === ['*'] ? res.fields : fields
	    ret = res.collect do |row|
		if ret_array
		    v = ret_fields.collect {|f| row[f.to_s]}
		    v.length == 1 ? v.first : v
		else
		    ret_fields.inject({}) do |memo, field|
			memo[field.to_sym] = row[field.to_s]
			memo
		    end
		end
	    end
	    res.clear
	    ret
	end
end
