#!/bin/bash

# assign public DNS access
echo nameserver > /etc/resolb.conf

# download Bind9
apt-get update
apt-get install bind9 -y

# Membuat direktori untuk DNS Zone
mkdir -p /etc/bind/arjuna
mkdir -p /etc/bind/abimanyu

# Konfigurasi DNS zone
echo "
zone \"arjuna.A12.com\" {
        type master;
  notify yes;
  also-notify { 10.5.2.3; };      # IP WerkudaraDNSSLave
  allow-transfer { 10.5.2.3; };    # IP WerkudaraDNSSLave
        file \"/etc/bind/arjuna/arjuna.A12.com\";
};

zone \"abimanyu.A12.com\" {
        type master;
  notify yes;
  also-notify { 10.5.2.3; };      # IP WerkudaraDNSSLave
  allow-transfer { 10.5.2.3; };    # IP WerkudaraDNSSLave
        file \"/etc/bind/abimanyu/abimanyu.A12.com\";
};

zone \"3.5.10.in-addr.arpa\" {
    type master;
    file \"/etc/bind/abimanyu/3.5.10.in-addr.arpa\";
};

" > /etc/bind/named.conf.local

# Konfigurasi DNS zone "arjuna.A12.com"
echo "
\$TTL 604800
@   IN  SOA     arjuna.A12.com. root.arjuna.A12.com. (
2023100901
604800
86400
2419200
604800
)
@   IN  NS      arjuna.A12.com.
@   IN  A       10.5.3.5
@   IN  AAAA    ::1
www IN  CNAME   arjuna.A12.com.
" > /etc/bind/arjuna/arjuna.A12.com

# Konfigurasi DNS zone "abimanyu.A12.com"
echo "
\$TTL 604800
@           IN  SOA     abimanyu.A12.com. root.abimanyu.A12.com. (
2023100901
604800
86400
2419200
604800
)
@           IN  NS      abimanyu.A12.com.
@           IN  A       10.5.3.3
@           IN  AAAA    ::1
www         IN  CNAME   abimanyu.A12.com.
parikesit   IN  CNAME   abimanyu.A12.com.
ns1         IN  A       10.5.2.3
baratayuda  IN  NS      ns1
rjp         IN  NS      ns1
www.rjp     IN  NS      ns1
" > /etc/bind/abimanyu/abimanyu.A12.com

# Konfigurasi reverse DNS
echo "
\$TTL 604800
@           IN  SOA     abimanyu.A12.com. root.abimanyu.A12.com. (
2023100901
604800
86400
2419200
604800
)
3.5.10.in-addr.arpa.   IN  NS  abimanyu.A12.com.
3                       IN  PTR abimanyu.A12.com.
" > /etc/bind/abimanyu/3.5.10.in-addr.arpa

# Konfigurasi option DNS server
echo "
options {
        directory \"/var/cache/bind\";
        allow-query{any;};
        auth-nxdomain no;    # conform to RFC1035
        listen-on-v6 { any; };
};" > /etc/bind/named.conf.options

# Memulai ulang BIND9
service bind9 restart