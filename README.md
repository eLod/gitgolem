# Golem

Golem provides an easy way to host and manage access to git repositories on a server under a single user.

## How it works

Golem's main goals are:

* host git repositories under a single user,
* manage access to repositories on a per-user basis,
* store users and keys in a database,
* to be simple as possible, but still extendable.

Golem is not designed to handle complex access rules, altough it may be extended to achieve that. If you need more refined rules, like per-branch or per-path control
you should check out {https://github.com/sitaramc/gitolite gitolite}, which has far superior features in this regard.

The git flow that golem supports is:

* you have a specific shell user that "hosts" golem,
* golem places your users ssh keys in this (shell) user's home directory (_~/.ssh/authorized\_keys_),
* your users use a git remote like _golem\_host\_user@your\_server:repository.git_,
* when a user git pushes/pulls, his git connects via ssh, sshd invokes golem's authorization command (via the _authorized\_keys_ file),
* golem authorizes the user for the given repository and invokes _git-shell_ if access granted.

## Configuration

Golem supports the following configuration variables:

* `db`: the database to use, currently postgres ('postgres://...') and static ('static') supported,
* `user_home`: the directory where the .ssh/authorized_keys file should be written, defaults to `HOME` environment variable,
* `repository_dir`: path to the git repositories, may be relative to `user_home`,
* `cfg_path`: path to config file, if not set searched for as (in this order):
  * `GOLEM_CONFIG` environment variable (if set),
  * 'golem.conf.rb' relative to `GOLEM_BASE` environment variable (if set),
  * /usr/local/etc/golem/golem.conf.rb,
  * /usr/local/etc/golem.conf.rb,
  * /etc/golem/golem.conf.rb,
  * /etc/golem.conf.rb,
  * ~/golem.conf.rb,
  * if found it is required (e.g. loaded), otherwise set to `base_dir + "/golem.conf.rb"` after configuration,
* `base_dir`: convenience feature, may be used to store installation, if not explicitly set defaults to:
  * `GOLEM_BASE` environment variable (if set),
  * basedir of `cfg_path` if file exists,
  * basedir of the library itself (e.g. the gem path),
* `bin_dir`: where the executable is installed, defaults to `base_dir + "/bin"`,
* `hooks_dir`: where the hooks are installed, defaults to `base_dir + "/hooks"`,
* `keys_file_use_command`: controls how to use `.ssh/authorized_keys` (_environment=""_ or _command=""_), see {file:README#keys_file authorized\_keys},
* `keys_file_ssh_opts`: ssh options to place in `.ssh/authorized_keys`, see {file:README#keys_file authorized\_keys}.

<a name="keys_file"></a>
## Git and .ssh/authorized_keys

Git supports SSH as the transport protocol for pulling and pushing, and assumes SSH for remotes like _user@server:/path/to/project.git_. With ssh remotes git executes remote commands, like
`git-receive-pack '/path/to/project.git'` (this is stored in `SSH_ORIGINAL_COMMAND` environment variable for the curious) when doing something like `git clone user@server:/path/to/project.git`.
Golem authorizes users so it must act before the actual git command runs. Key-based authentication is very popular and the `.ssh/authorized_keys` file allows a few possibilities to achieve what
golem tries to do, so it seems a natural fit. **Please note:** golem won't work without key-based authentication, as it relies content placed in the `.ssh/authorized_keys` file.

Golem by default requires that you set the users shell to `golem-auth` (wherever it is installed) that is "hosting" the repositories. With that setup golem can simply place lines like
`environment="GOLEM_USER='username'" ssh-dss AAA...` (where `AAA...` is the key) in the `.ssh/authorized_keys` file and `golem-auth` simply reads that environment variable. However this needs
that the user's shell is set to `golem-auth`, so golem provides a configuration variable, if you can't or simply don't want to change the user's shell. When `keys_file_use_command` is true golem
writes lines like `command="/path/to/golem-auth 'username'" ssh-dss AAA...` instead.

Golem supports another configuration variable called `keys_file_ssh_opts`, which is simply placed after the _environment=""_ or _command=""_ block. If `keys_file_use_command` is false (using
_environment=""_) golem simply injects the string into the lines, however if `keys_file_use_command` is true and `keys_file_ssh_opts` is not set (is `nil`) golem uses
{Golem::Command::UpdateKeysFile::SSH\_OPTS\_COMMAND\_DEFAULT} (if it is not `nil` golem uses the configuration value). The reasoning behind
this is golem assumes you control your SSHD's settings if using _environment=""_, but you may not set (global) restrictions when using _command=""_. The final line looks something like
`environment="GOLEM_USER='username'",ssh,opts ssh-dss AAA...` or `command="/path/to/golem-auth 'username'",ssh,opts ssh-dss AAA...`.

**Please note:** golem does not overwrite the whole `.ssh/authorized_keys` file.

## Database

Golem currently supports postgres and a static databases only, but it should be trivial to extend it (contributions are always welcome).

The static database is suitable for small installations (where an rdbms would be an overkill), to use it simply write:

  Golem.configure do |cfg|
    cfg.db = 'static'
    Golem::DB.setup do |db|
      db.add_user 'test_user'
      db.add_repository 'test_repository', 'test_user'
      db.add_key 'test_user', 'test_key'
    end
  end

The postgres database stores data in 3 tables (users, repositories, keys), and can be used with setting the db variable to the postgres url (e.g. `postgres://user:pw@host/db`).
A sample schema can be found in `lib/golem/db/postgres.sql`, and it is imported by {Golem::DB::Pg#setup} (please note: {Golem::DB.setup} forwards to it, should be called
only once).

At least users and repositories should have names, keys should have an attribute named `key` that is the whole key (e.g. cat id_rsa.pub).

## Access control

Golem's access control by default is very simple. It assumes a repository belongs to a single user, so it grants access to a given repository only to its owner.
For a very basic setup this should be enough. However for more complex setup Golem does not want to assume how you want to store your users and repositories, so
it simply doesn't. You can fine tune your environment to suit your specific needs with overriding {Golem::Access.check} (its arguments are the username, the repository
name and the git command to run (e.g. one of upload-pack, upload-archive and receive-pack)).

Golem's access control is done at the very beginning, before git-shell is run, so it's not suitable for per-branch or per-directory control. This can be achieved by hooks.
You should check out {https://github.com/sitaramc/gitolite gitolite}, which supports exactly that (and more). If you want you can place
{https://github.com/sitaramc/gitolite gitolite}'s hooks in Golem's `hooks_dir` and achieve the same results (this requires deeper understanding of git, so
please be aware).

## Commands

Golem provides an executable, and supports a few commands to easily automate the administration:

* auth: is used for authorization by sshd,
* clear_repositories: clear old data (e.g. suitable for cron),
* create_repository: create a repository manually (new repositories are created on first access by golem),
* delete_repository: delete a repository manually,
* environment: list configuration variables,
* save_config: save configuration variables,
* setup_db: setup database schema (useful for postgres only),
* update_hooks: update hooks in every repository,
* update_keys_file: update the .ssh/authorized_keys file.

You can get details about commands running `golem -h` or `--help`.

Golem provides another executable called `golem-auth`, which is a convenience script that calls `golem auth`.

## Contributing to golem

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it
* Fork the project
* Start a feature/bugfix branch
* Commit and push until you are happy with your contribution
* Make sure to add tests for it. This is important so I don't break it in a future version unintentionally.
* Please try not to mess with the Rakefile, version, or history. If you want to have your own version, or is otherwise necessary, that is fine, but please isolate to its own commit so I can cherry-pick around it.

## Copyright

Copyright (c) 2011 PoTa. See LICENSE.txt for
further details.

