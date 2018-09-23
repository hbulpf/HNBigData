
sudo systemctl stop sendmail
sudo systemctl stop postfix
sudo systemctl disable sendmail
sudo systemctl disable postfix
sudo yum -y install mailx

sudo cat <<EOM >>/etc/mail.rc
set from="1803838876@qq.com"   
set smtp=smtp.qq.com
set smtp-auth-user=1803838876@qq.com
set smtp-auth-password=haotiexin
set smtp-auth=login
EOM