    #!/bin/bash 
    sudo bash -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
    sudo apt-get update
    sudo apt-get -y install postgresql-16


    # Variables
    POSTGRESQL_CONF="/etc/postgresql/16/main/postgresql.conf"
    # worker IP
    worker_ip="$1" 
    # admin IP
    admin_ip="$2"
    #master IP
    master_ip=$(hostname -I)

    bash -c 'sudo chpasswd <<<"postgres:postgres"'


    # Update PostgreSQL configuration
    sudo sed -i 's/^port = .*$/port = 5432/' $POSTGRESQL_CONF
    sudo sed -i 's/^#listen_addresses = .*$/listen_addresses = '\''*'\''/' $POSTGRESQL_CONF
    sudo sed -i 's/^#wal_level = .*$/wal_level = replica/' $POSTGRESQL_CONF
    sudo sed -i 's/^#wal_log_hints = .*$/wal_log_hints = on/' $POSTGRESQL_CONF
    sudo sed -i 's/^#archive_mode = .*$/archive_mode = on/' $POSTGRESQL_CONF
    sudo sed -i "s~^#archive_command = .*~archive_command = 'test ! -f /var/lib/postgresql/16/main/archivedir/%f && cp %p /var/lib/postgresql/16/main/archivedir/%f'~" $POSTGRESQL_CONF
    sudo sed -i 's/^#max_wal_senders = .*$/max_wal_senders = 10/' $POSTGRESQL_CONF
    sudo sed -i 's/^#wal_keep_segments = .*$/wal_keep_segments = 10/' $POSTGRESQL_CONF



# Check if the directory exists
if [ ! -d "/var/lib/postgresql/16/main/archivedir/" ]; then
    sudo mkdir /var/lib/postgresql/16/main/archivedir/
fi

# Change ownership
sudo chown -R postgres:postgres /var/lib/postgresql/16/main/archivedir/




# Variables


pg_hba_conf="/etc/postgresql/16/main/pg_hba.conf"

new_line_replica="host\treplication\tall\t$worker_ip/24\ttrust"

sudo bash -c "echo \"$new_line_replica\" >> \"$pg_hba_conf\""


new_line_cluster="host\tclusterdb\tpostgres\t$admin_ip/24\ttrust"

sudo bash -c "echo \"$new_line_cluster\" >> \"$pg_hba_conf\""





sudo systemctl start postgresql

sudo -u postgres bash -c "createdb clusterdb"

# Execute SQL commands using psql
sudo -u postgres psql -d clusterdb -U postgres <<EOF
CREATE TABLE IF NOT EXISTS test_table(x integer);
INSERT INTO test_table(x) SELECT y FROM generate_series(1, 100) a(y);
EOF

