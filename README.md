terrecord
=========

This is simple O/R mapper based on "[T-ER Modeling Method] (http://www.sdi-net.co.jp/)".

## about

First of all, you should create DDL based on "T-ER Modeling Method".

On DDL, you must write "Comment" for each table & each field on our simple rule as follow (this is example about PostgreSQL).

    CREATE TABLE users (
        user_id INTEGER PRIMARY KEY
        , login_name VARCHAR(256) NOT NULL UNIQUE
        , password TEXT NOT NULL
        , status CHAR(1) NOT NULL DEFAULT 'A'
        , created TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
        , modified TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP
    );
    COMMENT ON TABLE users IS '[class User][desc the application user][type R][order login_name]';
    COMMENT ON COLUMN users.user_id IS '[member UserId][sequence user_id][desc internal user identifier]';
    COMMENT ON COLUMN users.login_name IS '[member LoginName][desc the user identifier string]';
    COMMENT ON COLUMN users.password IS '[member Password][desc the password string]';
    COMMENT ON COLUMN users.status IS '[member Status][desc the user status (Active/Inactive/Locked)][regexp "^[AIL]$"]';
    COMMENT ON COLUMN users.created IS '[member Created][type Created][desc record created timestamp]';
    COMMENT ON COLUMN users.modified IS '[member Modified][type Modified][desc record modified timestamp]';

And... build your database using it.

After this, run terrecord with your configuration.

Finally, you will get your class files as your Model.

### supported database engines

* PostgreSQL
* MySQL
* (you can add supporting classes for another database engine on this repository. please pull request!)

### supported application frameworks

* FuelPHP (PHP)
* (of course you can add supporthing classes for another framework on this repository. please pull request!)



## requirement

* This is implemented using PHP5.4 <=.
* PDO and PDO Driver which you will use (maybe PostgreSQL, MySQL and so on). 
* Smarty3


