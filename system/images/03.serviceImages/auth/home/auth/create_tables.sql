  CREATE TABLE IF NOT EXISTS users (
    userid VARCHAR(64) NOT NULL UNIQUE,
    passwd VARCHAR(32) NOT NULL,
    uid INTEGER NOT NULL UNIQUE,
    gid INTEGER,
    homedir VARCHAR(255),
    shell VARCHAR(255),
    last_accessed DATETIME
  );

  
CREATE TABLE IF NOT EXISTS groups (
    groupname VARCHAR(30) NOT NULL,
    gid INTEGER UNIQUE,
    members VARCHAR(255)
  );
   
    
  CREATE TABLE IF NOT EXISTS login_history (
    user VARCHAR(32) NOT NULL,
    client_ip VARCHAR(64) NOT NULL,
    server_ip VARCHAR(64) NOT NULL,
    protocol VARCHAR(16) NOT NULL,
    last_when DATETIME not null
  );
  
  #these baff if already created but who cares at this stage
  
  CREATE INDEX IF NOT EXISTS  groups_gid_idx ON groups (gid);
  CREATE INDEX IF NOT EXISTS  users_userid_idx ON users (userid);