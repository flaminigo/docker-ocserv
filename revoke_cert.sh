username=$1
cat user-$username/user-$username-cert.pem  > revoked.pem
certtool --generate-crl --load-ca-privkey ca-key.pem --load-ca-certificate ca.pem --load-certificate revoked.pem --template crl.tmpl --outfile /etc/ocserv/crl.pem

