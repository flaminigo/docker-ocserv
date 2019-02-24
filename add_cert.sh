function empty_revocation_list(){
#generate a empty revocation list
    [ ! -f crl.tmpl ] && {
    cat << _EOF_ >crl.tmpl
crl_next_update = 7777 
crl_number = 1 
_EOF_
    certtool --generate-crl --load-ca-privkey ca-key.pem --load-ca-certificate ca.pem --template crl.tmpl --outfile /etc/ocserv/crl.pem
    }
}

if [ "$#" -ne 2 ]; then
    echo "usage: add_cert.sh [username] [cert password]"
    exit
fi

caname=`openssl x509 -noout -text -in ca.pem|grep Subject|sed -n 's/.*CN=\([^/,]*\).*/\1/p'` && echo $caname
name_user_ca=$1
password=$2
echo $name_user_ca

mkdir user-${name_user_ca}
oc_ex_days=7777

cat << _EOF_ > user-${name_user_ca}/user.tmpl
cn = "${name_user_ca}"
unit = "Route"
#unit = "All"
uid ="${name_user_ca}"
expiration_days = ${oc_ex_days}
signing_key
tls_www_client
_EOF_

#Generate user key
openssl genrsa -out user-${name_user_ca}/user-${name_user_ca}-key.pem 2048

#Generate user cert
    certtool --generate-certificate --hash SHA256 --load-privkey user-${name_user_ca}/user-${name_user_ca}-key.pem --load-ca-certificate ca.pem --load-ca-privkey ca-key.pem --template user-${name_user_ca}/user.tmpl --outfile user-${name_user_ca}/user-${name_user_ca}-cert.pem
#p12
    openssl pkcs12 -export -inkey user-${name_user_ca}/user-${name_user_ca}-key.pem -in user-${name_user_ca}/user-${name_user_ca}-cert.pem -name "${name_user_ca}" -certfile ca.pem -caname "$caname" -out user-${name_user_ca}/user-${name_user_ca}.p12 -passout pass:$password
#cp to ${Script_Dir}
    #cp user-${name_user_ca}/user-${name_user_ca}.p12 ${Script_Dir}/${name_user_ca}.p12
    empty_revocation_list
    echo "Generate client cert ok"
