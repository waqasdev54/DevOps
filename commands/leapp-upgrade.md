curl -I https://yum.oracle.com/repo/OracleLinux/OL8/baseos/latest/x86_64/

setenv=LEAPP_ENABLE_REPOS=ol8_basemediol_ol8_appstream_ol8_UEKR6_ol8_addons_ol8_kplice_ol8_developer

sudo yum-config-manager --enable ol8_baseos_latest ol8_appstream ol8_UEKR6
sudo yum repolist

sudo yum --releasever=8.10 search libgpg-error
sudo yum --releasever=8.10 search python3-dnf


sudo yum clean all
sudo rm -rf /var/cache/yum


