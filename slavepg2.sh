

#!/bin/bash 


master_ip="$1"

worker_ip=$(hostname -I)

vip="$2"

POSTGRESQL_CONF="/etc/postgresql/16/main/postgresql.conf"


# Log in as postgres user on the remote server
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa <<< y

ssh-copy-id  postgres@"$master_ip"



sudo apt-get install keepalived -y
sudo mkdir /etc/keepalived/scripts




 

echo "#!/bin/bash
# Run me on the Master
 

pg_ctl=\"/usr/lib/postgresql/16/bin/pg_ctl\"
pg_home=\"/var/lib/postgresql/16/main/\"
 
(echo >/dev/tcp/$master_ip/5432) &>/dev/null && echo \"All is OK\" || ssh postgres@$worker_ip \"\$pg_ctl -D \$pg_home promote\"
exit \$?" | sudo tee /etc/keepalived/scripts/check_postgres


sudo chmod +x /etc/keepalived/scripts/check_postgres








sudo bash -c 'echo " 
vrrp_script chk_pg_port {
        script "/bin/bash /etc/keepalived/scripts/check_postgres"
        interval 2
        weight 2
}
vrrp_instance VI_1 {
        interface enp0s8
        state MASTER
        virtual_router_id 51
        priority 100
        authentication {
            auth_type PASS
            auth_pass postgres
        }
        track_script {
            chk_pg_port
        }
        virtual_ipaddress {
              vip-placeholder/24 dev enp0s8
        }" >  /etc/keepalived/keepalived.conf'



sudo sed -i "s/vip-placeholder/$vip/" /etc/keepalived/keepalived.conf


sudo systemctl start keepalived

