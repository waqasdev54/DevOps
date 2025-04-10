# PHP 7.4 to PHP 8 Upgrade Guide for RHEL 7.9

This guide outlines the steps to upgrade from PHP 7.4.33 to PHP 8 on Red Hat Enterprise Linux 7.9.

## Prerequisites

* Red Hat Enterprise Linux 7.9 system
* Root or sudo access
* Current PHP version 7.4.33
* Backup of your PHP applications and configuration files

## Step 1: Backup Current PHP Configuration

Before beginning the upgrade process, back up your current PHP configuration files:

```bash
sudo mkdir -p /backup/php7
sudo cp -rf /etc/php.ini /backup/php7/
sudo cp -rf /etc/php.d/ /backup/php7/
sudo cp -rf /var/www/html/ /backup/php7/  # If applicable
```

## Step 2: Install Required Repositories

### IMPORTANT: Alternate Method - Skip EPEL and Use Remi Directly

Since you're encountering persistent issues with the EPEL repository, we'll use an alternative approach by installing Remi repository directly:

```bash
# Download the Remi RPM directly
wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm

# Install the Remi RPM package
sudo rpm -Uvh remi-release-7.rpm

# Install yum-utils
sudo yum install -y yum-utils
```

## Step 3: Configure PHP 8 Repository

Choose which PHP 8 version you want to install. For this guide, we'll use PHP 8.2 as an example:

```bash
# Enable PHP 8.2
sudo yum-config-manager --enable remi-php82
```

## Step 4: Upgrade PHP

```bash
# Update yum cache
sudo yum clean all
sudo yum makecache

# Remove the old PHP packages (optional, but recommended to avoid conflicts)
sudo yum remove -y php-*

# Install PHP 8.2 and common extensions
sudo yum install -y php php-cli php-common php-fpm php-mysqlnd php-zip php-devel php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json php-intl php-opcache
```

Note: Adjust the extensions based on your specific requirements.

## Step 5: Verify PHP Version

```bash
php -v
```

The output should show PHP 8.2.x.

## Step 6: Update PHP Configuration

Review and update your PHP configuration files as needed:

```bash
sudo vi /etc/php.ini
```

PHP 8 might have different default settings, so compare with your backed-up configuration and adjust accordingly.

## Step 7: Restart Web Server

If you're using Apache:

```bash
sudo systemctl restart httpd
```

If you're using Nginx with PHP-FPM:

```bash
sudo systemctl restart php-fpm
sudo systemctl restart nginx
```

## Step 8: Test Your Applications

Test your PHP applications for compatibility issues. PHP 8 introduces several breaking changes compared to PHP 7.4.

## Common Issues and Solutions

### Troubleshooting Repository Issues

If you continue to have issues with the repositories:

1. **Check network connectivity**:
   ```bash
   ping 8.8.8.8
   ```

2. **Verify DNS resolution**:
   ```bash
   nslookup rpms.remirepo.net
   ```

3. **Try with disabled SELinux temporarily**:
   ```bash
   sudo setenforce 0
   ```
   (Remember to re-enable it after installation: `sudo setenforce 1`)

4. **Check if your system is behind a proxy**:
   If so, configure yum to use your proxy:
   ```bash
   # Add to /etc/yum.conf
   proxy=http://proxy.example.com:3128
   ```

5. **Try with an alternate DNS server**:
   ```bash
   echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf
   ```

### Application Compatibility

PHP 8 deprecates and removes several features from PHP 7.4. Some common issues include:

1. **Removed Functions**: Some functions have been removed in PHP 8
2. **Stricter Type Checking**: PHP 8 has stricter type checking
3. **Constructor Property Promotion**: New feature in PHP 8 that may affect OOP code

Run the following command to check for potential compatibility issues:

```bash
find /path/to/your/code -name "*.php" -exec php -l {} \;
```

### Extension Compatibility

Some extensions might not be available or work differently in PHP 8. Check each extension's documentation for PHP 8 compatibility.

## Rollback Procedure

If you encounter critical issues and need to revert to PHP 7.4:

```bash
# Remove PHP 8
sudo yum remove -y php-*

# Enable PHP 7.4 repository
sudo yum-config-manager --disable remi-php82
sudo yum-config-manager --enable remi-php74

# Reinstall PHP 7.4
sudo yum install -y php php-cli php-common php-fpm php-mysqlnd php-zip php-devel php-gd php-mbstring php-curl php-xml php-pear php-bcmath php-json

# Restore your backup configurations
sudo cp -rf /backup/php7/php.ini /etc/
sudo cp -rf /backup/php7/php.d/* /etc/php.d/

# Restart web server
sudo systemctl restart httpd  # or nginx and php-fpm
```

## Resources

- [PHP 8.2 Documentation](https://www.php.net/releases/8.2/en.php)
- [PHP 8.2 Migration Guide](https://www.php.net/manual/en/migration82.php)
- [Remi Repository Documentation](https://blog.remirepo.net/pages/Config-en)
- [RHEL Documentation](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7)
