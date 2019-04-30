#!/bin/bash

# This script aims to automagically configure a proper HTTPS certificate for a HySDS instance
# The Let's Encrypt CA will NOT issue certificates for ephemeral domain names such as AWS EC2 domains!
# Please obtain a proper domain name before attempting to run this tool

echo "🔐 HTTPS Let's Encrypt Autoconfiguration Tool for CentOS/Apache🔐"

read -r -e -p "Please enter the Fully Qualified Domain Name of this server: " FQDN
read -r -e -p "Please enter your CloudFlare login email: " CLOUDFLARE_LOGIN
read -r -e -p "Please enter your CloudFlare Global API Key: " CLOUDFLARE_API_KEY
echo

echo "➡️  Reconfiguring HTTPS settings for httpd to enhance security..."

# Replace old cipher suite configuration with more robust cipher suite
sudo sed -i 's/SSLCipherSuite HIGH:MEDIUM:!aNULL:!MD5:!SEED:!IDEA/SSLCipherSuite EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:ECDHE-RSA-AES128-SHA:DHE-RSA-AES128-GCM-SHA256:AES256+EDH:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA384:ECDHE-RSA-AES128-SHA256:ECDHE-RSA-AES256-SHA:DHE-RSA-AES256-SHA256:DHE-RSA-AES128-SHA256:DHE-RSA-AES256-SHA:DHE-RSA-AES128-SHA:ECDHE-RSA-DES-CBC3-SHA:EDH-RSA-DES-CBC3-SHA:AES256-GCM-SHA384:AES128-GCM-SHA256:AES256-SHA256:AES128-SHA256:AES256-SHA:AES128-SHA:DES-CBC3-SHA:HIGH:!aNULL:!eNULL:!EXPORT:!DES:!MD5:!PSK:!RC4/g' /etc/httpd/conf.d/ssl.conf

# Disable SSL version 3 in addition to SSL version 2
sudo sed -i 's/SSLProtocol all -SSLv2/SSLProtocol All -SSLv2 -SSLv3/g' /etc/httpd/conf.d/ssl.conf

# Enable Honor Cipher Order
sudo sed -i 's/#SSLHonorCipherOrder on/SSLHonorCipherOrder on/g' /etc/httpd/conf.d/ssl.conf

echo "➡️  Installing required packages..."

# Install certbot for automatic certificate issuance from Let's Encrypt
sudo yum install -y python2-certbot-apache
sudo yum install -y python2-cloudflare python2-certbot-dns-cloudflare

echo "➡️  Creating basic directories with an intentionally malformed command, ignore warnings below..."

# Issue a certificate. This should only be run once, with subsequent runs done with certbot renew
sudo certbot --apache certonly -d "$FQDN" --register-unsafely-without-email --agree-tos -n

# The above should fail, but it will automatically create a bunch of directories which we need

echo "➡️  Configuring CloudFlare DNS..."

# Insert the email and API key of the user into the configuration
if [[ -f "/etc/letsencrypt/cloudflareapi.cfg" ]]; then
    # If configuration file already exists, delete and recreate it
    sudo rm /etc/letsencrypt/cloudflareapi.cfg
fi
sudo touch /etc/letsencrypt/cloudflareapi.cfg
echo "dns_cloudflare_email = $CLOUDFLARE_LOGIN" | sudo tee -a /etc/letsencrypt/cloudflareapi.cfg
echo "dns_cloudflare_api_key = $CLOUDFLARE_API_KEY" | sudo tee -a /etc/letsencrypt/cloudflareapi.cfg
sudo chmod 600 /etc/letsencrypt/cloudflareapi.cfg

# Now let's try registering again
sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflareapi.cfg -d "$FQDN" --register-unsafely-without-email --agree-tos -n

echo "➡️  Please check if the above output is correct and that the certificate was correctly installed"

# Let the user manually check if the issuance of the certificate was a success
read -n 1 -s -r -p "Press any key to continue or press Ctrl-C to abort..."

echo
echo "➡️  Modifying httpd configuration files for the new certificates..."

# Insert certificates into httpd's configuration
sudo sed -i "s|\("^SSLCertificateFile" * *\).*|\1/etc/letsencrypt/live/$FQDN/fullchain.pem|" /etc/httpd/conf.d/ssl.conf
sudo sed -i "s|\("^SSLCertificateKeyFile" * *\).*|\1/etc/letsencrypt/live/$FQDN/privkey.pem|" /etc/httpd/conf.d/ssl.conf
sudo sed -i "s|\("^SSLCertificateChainFile" * *\).*|\1/etc/letsencrypt/live/$FQDN/chain.pem|" /etc/httpd/conf.d/ssl.conf

#old version for certificate insertion
# sudo sed -i "s/SSLCertificateFile \/etc\/pki\/tls\/certs\/localhost.crt/SSLCertificateFile \/etc\/letsencrypt\/live\/$FQDN\/fullchain.pem/g" /etc/httpd/conf.d/ssl.conf
# sudo sed -i "s/SSLCertificateKeyFile \/etc\/pki\/tls\/private\/localhost.key/SSLCertificateKeyFile \/etc\/letsencrypt\/live\/$FQDN\/privkey.pem/g" /etc/httpd/conf.d/ssl.conf
# sudo sed -i "s/#SSLCertificateChainFile \/etc\/pki\/tls\/certs\/server-chain.crt/SSLCertificateChainFile \/etc\/letsencrypt\/live\/$FQDN\/chain.pem/g" /etc/httpd/conf.d/ssl.conf

# Restart httpd
echo "➡️  Restarting httpd..."
sudo systemctl restart httpd.service

# Add renewal script
echo "➡️  Adding automatic renewal cron job..."
echo

if cat /etc/letsencrypt/renewal/"$FQDN".conf | grep -q "renew_hook = systemctl reload httpd"; then
    echo "Renew hook in /etc/letsencrypt/renewal/$FQDN.conf already exists, no need to modify file"
else
    echo "renew_hook = systemctl reload httpd" | sudo tee -a /etc/letsencrypt/renewal/"$FQDN".conf
fi

if sudo crontab -l | grep -q "certbot renew"; then
    echo "Crontab for automatic certificate renewal already exists, no need to modify file"
else
    sudo crontab -l > cron.tmp
    echo "30 2 * * * certbot renew -n" >> cron.tmp
    sudo crontab cron.tmp
    rm -f cron.tmp
fi

echo "✅  HTTPS configuration complete!"
