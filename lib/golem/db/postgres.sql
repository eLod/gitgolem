CREATE TABLE users (
    name varchar(32) NOT NULL PRIMARY KEY,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE keys (
    user_name varchar(32) NOT NULL REFERENCES users (name) ON DELETE no action ON UPDATE no action,
    key varchar(1024) NOT NULL UNIQUE,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_name, key)
);

CREATE TABLE repositories (
    name varchar(32) NOT NULL PRIMARY KEY,
    user_name varchar(32) NOT NULL REFERENCES users (name) ON DELETE no action ON UPDATE no action,
    created_at timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
);
