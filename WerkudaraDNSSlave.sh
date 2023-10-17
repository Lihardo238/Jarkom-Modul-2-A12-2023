#!/bin/bash

# assign public DNS access
echo nameserver > /etc/resolb.conf

# download Bind9
apt-get update
apt-get install bind9 -y

# Membuat direktori untuk DNS Zone
mkdir -p /etc/bind/arjuna
mkdir -p /etc/bind/abimanyu
mkdir -p /etc/bind/baratayuda

# Konfigurasi DNS Zone
echo "
zone \"arjuna.A12.com\" {
type slave;
masters { 10.5.2.2; };          # IP YudhistiraDNSMaster
file \"/etc/bind/arjuna/arjuna.A12.com\";
};

zone \"abimanyu.A12.com\" {
type slave;
masters { 10.5.2.2; };          # IP YudhistiraDNSMaster
file \"/etc/bind/abimanyu/abimanyu.A12.com\";
};

zone \"baratayuda.abimanyu.A12.com\" {
type master;
file \"/etc/bind/baratayuda/baratayuda.abimanyu.A12.com\";
};

" > /etc/bind/named.conf.local

# Konfigurasi option DNS server
echo "
options {
        directory \"/var/cache/bind\";
        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};" > /etc/bind/named.conf.options

# Konfigurasi zone "baratayuda.abimanyu.A12.com"
echo "
\$TTL 604800
@               IN  SOA     baratayuda.abimanyu.A12.com. root.baratayuda.abimanyu.A12.com. (
2023100901
604800
86400
2419200
604800
)
@               IN      NS              baratayuda.abimanyu.A12.com.
@               IN      A               10.5.3.3
www     IN  CNAME   baratayuda.abimanyu.A12.com.
rjp             IN      CNAME   baratayuda.abimanyu.A12.com.
www.rjp IN      CNAME   baratayuda.abimanyu.A12.com.
" > /etc/bind/baratayuda/baratayuda.abimanyu.A12.com

# Memulai ulang BIND9
service bind9 restart