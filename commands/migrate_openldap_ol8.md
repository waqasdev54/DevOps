```markdown
# OpenLDAP Migration Guide: Oracle Linux 7.9 to Oracle Linux 8

## 1. Backup OpenLDAP Data on OL7.9

### Stop OpenLDAP Service
```bash
sudo systemctl stop slapd  # Stop the service to ensure data consistency
```

### Export Database to LDIF
```bash
sudo slapcat -n 1 -l /tmp/backup.ldif  # Export all entries to backup.ldif
```

### Backup Configuration Files
```bash
sudo tar czvf /tmp/openldap_backup.tar.gz \
  /etc/openldap/slapd.d/ \
  /var/lib/ldap/ \
  /etc/sysconfig/slapd  # Archive config, DB, and service settings
```

### Transfer Backups to OL8
```bash
# From OL8, pull files using scp:
scp user@ol7-host:/tmp/backup.ldif /tmp/
scp user@ol7-host:/tmp/openldap_backup.tar.gz /tmp/
```

---

## 2. Install OpenLDAP on Oracle Linux 8

### Install Packages
```bash
sudo dnf install openldap-servers openldap-clients openldap-devel -y  # Core OpenLDAP packages
```

### Temporarily Start Service (for setup)
```bash
sudo systemctl enable slapd && sudo systemctl start slapd  # Start slapd to initialize defaults
sudo systemctl stop slapd  # Stop to restore configs later
```

---

## 3. Restore Configuration on OL8

### Extract Backup
```bash
sudo tar xzvf /tmp/openldap_backup.tar.gz -C /  # Overwrite default OL8 configs
```

### Fix Permissions
```bash
sudo chown -R ldap:ldap /etc/openldap/slapd.d/  # Ensure LDAP user owns configs
sudo chown -R ldap:ldap /var/lib/ldap/  # Correct ownership for database files
```

### (Optional) Convert slapd.conf to OLC Format
```bash
# Only needed if migrating from slapd.conf (OL7.9 legacy):
sudo mkdir -p /etc/openldap/slapd.d
sudo slaptest -f /etc/openldap/slapd.conf -F /etc/openldap/slapd.d/  # Convert config
sudo chown -R ldap:ldap /etc/openldap/slapd.d/  # Fix permissions again
```

---

## 4. Restore Database on OL8

### Delete Default Database (if exists)
```bash
sudo rm -rf /var/lib/ldap/*  # Remove empty default DB
```

### Import LDIF Backup
```bash
sudo slapadd -n 1 -l /tmp/backup.ldif  # Load data into new OL8 DB
```

### Fix Database Permissions
```bash
sudo chown -R ldap:ldap /var/lib/ldap/  # Critical for slapd to access DB
```

---

## 5. Configure TLS (Optional)

### Copy Certificates
```bash
# Place your certs in /etc/openldap/certs/:
sudo mkdir -p /etc/openldap/certs
sudo cp ldap.crt ldap.key ca.crt /etc/openldap/certs/
sudo chown -R ldap:ldap /etc/openldap/certs/  # Ensure LDAP user can read certs
```

### Update TLS Config
```bash
# Edit /etc/openldap/slapd.d/cn=config.ldif and add:
olcTLSCACertificateFile: /etc/openldap/certs/ca.crt
olcTLSCertificateFile: /etc/openldap/certs/ldap.crt
olcTLSCertificateKeyFile: /etc/openldap/certs/ldap.key
olcTLSCipherSuite: HIGH+TLSv1.2
```

---

## 6. Start Service & Validate

### Start OpenLDAP
```bash
sudo systemctl start slapd && sudo systemctl status slapd  # Verify service is active
```

### Test LDAP Query
```bash
ldapsearch -x -LLL -H ldap://localhost -b "dc=example,dc=com" "(objectClass=*)"  # Replace with your base DN
```

---

## 7. Post-Migration Tasks

### Configure Firewall
```bash
sudo firewall-cmd --add-service={ldap,ldaps} --permanent  # Allow LDAP/LDAPS
sudo firewall-cmd --reload
```

### Fix SELinux Contexts
```bash
sudo restorecon -Rv /etc/openldap /var/lib/ldap  # Ensure SELinux allows access
```

---

## 8. Troubleshooting

### Check Logs
```bash
sudo journalctl -u slapd -f  # Tail slapd logs in real-time
```

### Validate Config Syntax
```bash
sudo slaptest -u  # Check for configuration errors
```

### Reindex Database (if entries are missing)
```bash
sudo systemctl stop slapd
sudo slapindex -n 1  # Rebuild indices
sudo chown -R ldap:ldap /var/lib/ldap/
sudo systemctl start slapd
```

---

## 9. Rollback Plan

### Restore OL7.9
- Restart the original OL7.9 server with its backups.

### Reset OL8 to Defaults
```bash
sudo rm -rf /etc/openldap/slapd.d/* /var/lib/ldap/*
sudo dnf reinstall openldap-servers -y  # Reinstall packages
```

---
