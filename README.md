# Docker image for PHP Magento 2.2

Docker for build system ( Pipeline Deployment )

Customs:
- workdir **/srv/magento2**
- user **magento** with uid **2000**
- installed composer
- installed git
- installed magerun2
- ssmtp with default host MAILHOG_app


```bash
docker run -v /path/to/your/magento:/srv/magento2 -v /path/to/composer/data:/home/magento/.composer -e GITHUB_OAUTH=${GITHUB_OAUTH} --rm -it bmxmale/magento2-php:2.2-build bash
```

Told composer that we will use __GITHUB_OAUTH__
```bash
composer config -g github-oauth.github.com ${GITHUB_OAUTH}
```

Run composer on update dir, needed for cron
```bash
cd update
composer install --ignore-platform-reqs --optimize-autoloader --no-dev
```

Run composer on main dir
```bash
composer install --ignore-platform-reqs --optimize-autoloader --no-dev
```


```bash
php bin/magento setup:di:compile

# This will work only for en_US, if you have selected other locales you need to declare it as param
php bin/magento setup:static-content:deploy -f
```


For static-content deploy on offline system you need to remove __app/etc/env.php__