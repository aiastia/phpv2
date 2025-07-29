FROM php:7.4-fpm

# 安装系统依赖
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    supervisor \
    cron \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev

# 安装PHP扩展
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip fileinfo
RUN pecl install redis && docker-php-ext-enable redis

# 配置PHP设置
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" && \
    sed -i 's/disable_functions =.*/disable_functions =/g' $PHP_INI_DIR/php.ini

# 安装Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# 复制配置文件
COPY supervisor.conf /etc/supervisor/conf.d/supervisor.conf
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 设置工作目录
WORKDIR /var/www/html

# 设置容器启动命令
CMD ["/usr/local/bin/entrypoint.sh"]
