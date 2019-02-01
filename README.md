# Docker image for PHP Magento 2.3

Customs:
- workdir **/srv/magento2.3**
- user **magento** with uid **1000**
- installed newrelic php agent
- installed xdebug on port 9001
- installed composer
- installed magerun2
- ssmtp with default host MAILHOG_app

```bash
version: '3'
services:
  php:
    image: bmxmale/magento2-php:latest
    environment:
      - NEWRELIC_APPNAME=Magento2-PHP
      - NEWRELIC_KEY=###########################
networks:
    default:
        external:
            name: MAGENTO_network
```
**MailHog**

```bash
docker stack up -c mailhog.yml MAILHOG_app
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