#!/bin/bash

chown -R postgres /var/lib/postgresql
chown postgres -R /var/log/postgresql/



 service postgresql restart