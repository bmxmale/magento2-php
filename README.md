# Docker image for PHP Magento 2.2

Customs:
- workdir **/srv/magento2**
- user **magento** with uid **2000**
- installed newrelic php agent
- installed xdebug on port 9001
- installed composer
- installed magerun2
- cron with magento job
- ssmtp with default host MAILHOG_app

```bash
version: '3'
services:
  php:
    image: bmxmale/magento2-php:latest
    environment:
    #  - ENABLE_XDEBUG=1
      - NEWRELIC_APPNAME=Magento2-PHP
      - NEWRELIC_KEY=###########################
networks:
    default:
        external:
            name: MAGENTO_network
```
**MailHog**

```bash
docker stack up -c mailhog.yml MAILHOG
```

**mailhog.yml**

```bash
version: '3'
services:
  app:
    image: mailhog/mailhog
    deploy:
      mode: global
networks:
    default:
        external:
            name: MAGENTO_network
```