#!/bin/bash 
sudo sh -c 'echo "deb https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get update
sudo apt-get -y install postgresql-16

# master IP
master_ip="$1"
# admin IP
admin_ip="$2"
# worker IP
worker_ip=$(hostname -I)




sudo systemctl stop postgresql
sudo mv /var/lib/postgresql/16 /root

bash -c 'sudo chpasswd <<<"postgres:postgres"'



sudo -i -u postgres bash -c "pg_basebackup -h $master_ip -U postgres -D /var/lib/postgresql/16/main -P -Xs -R"





# Variables



POSTGRESQL_CONF="/etc/postgresql/16/main/postgresql.conf"

# Update PostgreSQL configuration
sudo sed -i 's/^port = .*$/port = 5432/' $POSTGRESQL_CONF
sudo sed -i 's/^#listen_addresses = .*$/listen_addresses = '\''*'\''/' $POSTGRESQL_CONF
sudo sed -i 's/^#wal_level = .*$/wal_level = replica/' $POSTGRESQL_CONF
sudo sed -i 's/^#archive_mode = .*$/archive_mode = on/' $POSTGRESQL_CONF
sudo sed -i "s~^#archive_command = .*~archive_command = 'test ! -f /var/lib/postgresql/16/main/archivedir/%f && cp %p /var/lib/postgresql/16/main/archivedir/%f'~" $POSTGRESQL_CONF
sudo sed -i "s~^#restore_command = .*~restore_command = 'cp /var/lib/postgresql/16/main/archivedir/%f %p'~" $POSTGRESQL_CONF
sudo sed -i "s~^#archive_cleanup_command = .*~archive_cleanup_command = 'pg_archivecleanup /var/lib/postgresql/16/main/archivedir %r'~" $POSTGRESQL_CONF
sudo sed -i 's/^#max_wal_senders = .*$/max_wal_senders = 10/' $POSTGRESQL_CONF
sudo sed -i 's/^#wal_keep_segments = .*$/wal_keep_segments = 10/' $POSTGRESQL_CONF
sudo sed -i "s~^#hot_standby = .*~hot_standby = on~" $POSTGRESQL_CONF





# Variables


pg_hba_conf="/etc/postgresql/16/main/pg_hba.conf"

new_line_replica="host\treplication\tall\t$worker_ip/24\ttrust"

sudo bash -c "echo \"$new_line_replica\" >> \"$pg_hba_conf\""


new_line_cluster="host\tclusterdb\tpostgres\t$admin_ip/24\ttrust"

sudo bash -c "echo \"$new_line_cluster\" >> \"$pg_hba_conf\""



sudo systemctl start postgresql



psql -d clusterdb -h $worker_ip -U postgres -c "SELECT count(*) from test_table"


