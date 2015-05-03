  CREATE TABLE users (
    userid VARCHAR(30) NOT NULL UNIQUE,
    passwd VARCHAR(80) NOT NULL,
    uid INTEGER NOT NULL UNIQUE,
    gid INTEGER,
    homedir VARCHAR(255),
    shell VARCHAR(255)
    last_accessed DATETIME
  );

  CREATE INDEX users_userid_idx ON users (userid);
  
CREATE TABLE groups (
    groupname VARCHAR(30) NOT NULL,
    gid INTEGER UNIQUE,
    members VARCHAR(255)
  );
   CREATE INDEX groups_gid_idx ON groups (gid);
   
   
  CREATE TABLE login_history (
    user VARCHAR NOT NULL,
    client_ip VARCHAR NOT NULL,
    server_ip VARCHAR NOT NULL,
    protocol VARCHAR NOT NULL,
    when DATETIME
  );
  