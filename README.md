# Jarkom-Modul-2-A12-2023
- Shaula Aljauhara Riyadi 5025201265
- Lihardo Marson Purba 5025211238

## Topologi
![Ss Soal1](image/Screenshot%202023-10-17%20150817.png)

## Daftar IP address 
![Ss Soal1](image/Screenshot%202023-10-17%20151920.png)

## Konfigurasi Yudhistira DNS Master
Script pada Yudhistira
```bash
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
```
Penjelasan :
- sebelum kita ingin mendownload dependencies app yang diperlukan, Kita perlu melakukan connecting IP local dengan IP public yang terhubung ke Pandudewananta sebagai router yang terhubung ke NAT
  - kita masukkan ke /etc/resolv.conf pada setiap node yang di dapat dari Pandudewananta
    ![Ss Soal1](image/Screenshot%202023-10-17%20153245.png)
- kita perlu mendownload bind9 sebagai software DNS server
  ```bash
    apt-get update
    apt-get install bind9 -y
  ```
- konfigurasi Domain arjuna.A12.com pada /etc/bind/named.conf.local
  ```bash
    zone \"arjuna.A12.com\" {
        type master;
        notify yes;
        also-notify { 10.5.2.3; };      # IP WerkudaraDNSSLave
        allow-transfer { 10.5.2.3; };    # IP WerkudaraDNSSLave
        file \"/etc/bind/arjuna/arjuna.A12.com\";
  };
  ```
- Konfigurasi Domain abimanyu.A12.com pada /etc/bind/named.conf.local
  ```bash
    zone \"abimanyu.A12.com\" {
        type master;
        notify yes;
        also-notify { 10.5.2.3; };      # IP WerkudaraDNSSLave
        allow-transfer { 10.5.2.3; };    # IP WerkudaraDNSSLave
        file \"/etc/bind/abimanyu/abimanyu.A12.com\";
    };
  ```
- Konfigurasi reverse Domain abimanyu pada /etc/bind/named.conf.local
  ```bash
    zone \"3.5.10.in-addr.arpa\" {
        type master;
        file \"/etc/bind/abimanyu/3.5.10.in-addr.arpa\";
    };
  ```
- Konfigurasi arjuna.A12.com domain master pada /etc/bind/arjuna/arjuna.A12.com
  ```bash
    $TTL 604800
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
  ```

- Konfigurasi abimanyu.A12.com domain master pada /etc/bind/abimanyu/abimanyu.A12.com
  ```bash
    $TTL 604800
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
  ```

- konfigurasi reverse  abimanyu.A12.com pada /etc/bind/abimanyu/3.5.10.in-addr.arpa
  ```bash
    $TTL 604800
    @           IN  SOA     abimanyu.A12.com. root.abimanyu.A12.com. (
    2023100901
    604800
    86400
    2419200
    604800
    )
    3.5.10.in-addr.arpa.   IN  NS  abimanyu.A12.com.
    3                       IN  PTR abimanyu.A12.com.
  ```
## Konfigurasi Werkudara DNS Slave
Script pada Werkudara
```bash
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
```

Penjelasan :
- sama seperti sebelumnya kita perlu download bind9 sebagai server DNS
- Konfigurasi DNS slave dari arjuna.A12.com dan abimanyu.A12.com pada /etc/bind/named.conf.local
  ```bash
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
  ```
- konfigurasi sub domain baratayuda.abimanyu.A12.com pada /etc/bind/named.conf.local
  ```bash
    zone \"baratayuda.abimanyu.A12.com\" {
    type master;
    file \"/etc/bind/baratayuda/baratayuda.abimanyu.A12.com\";
    };
  ```
-konfigurasi konfigurasi sub domain baratayuda.abimanyu.A12.com pada /etc/bind/baratayuda/baratayuda.abimanyu.A12.com
  ```bash
    $TTL 604800
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
  ```

## Demo DNS server
- kita melakukan ping dari node Wisanggeni dengan prequisite /etc/resolv.conf sebagai berikut. 
  ![Ss Soal1](image/Screenshot%202023-10-17%20160631.png)
- Menjalankan bind9 pada Yudhistira
  ```bash
    service bind9 start
  ```
- Ping ke arjuna.A12.com & www.arjuna.A12.com
  ![Ss Soal1](image/Screenshot%202023-10-17%20161228.png)
- Ping ke abimanyu.A12.com & www.abimanyu.A12.com
  ![Ss Soal1](image/Screenshot%202023-10-17%20161852.png)
- ping ke parikesit.abimanyu.A12.com & www.parikesit.abimanyu.A12.com
  ![Ss Soal1](image/Screenshot%202023-10-17%20184454.png)
- check reverse abimanyu domain
  ![Ss Soal1](image/Screenshot%202023-10-17%20185550.png)
- server slave check
  - mematikan DNS server Yudhistira
    ![Ss Soal1](image/Screenshot%202023-10-17%20191026.png)
  - ping ke domain arjuna.A12.com & abimanyu.A12.com
    ![Ss Soal1](image/Screenshot%202023-10-17%20191422.png)
-ping baratayuda.A12.com & www.baratayuda.A12.com
  ![Ss Soal1](image/Screenshot%202023-10-17%20191727.png)
-ping sub domain rjp
  ![Ss Soal1](image/Screenshot%202023-10-17%20192130.png)
