#!/bin/bash

# 仅在首次运行时初始化
if [ ! -f "/var/www/html/initialized" ]; then
    echo "Starting initial setup..."
    
    # 克隆V2Board（如果目录为空）
    if [ -z "$(ls -A /var/www/html)" ]; then
        git clone https://github.com/v2board/v2board.git /tmp/v2board
        shopt -s dotglob
        mv /tmp/v2board/* /var/www/html/
        rm -rf /tmp/v2board
    fi
    
    # 安装依赖
    composer install --no-dev --optimize-autoloader
    
    # 创建环境文件
    cat > .env <<EOF
APP_NAME=V2Board
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=${APP_URL}

DB_CONNECTION=mysql
DB_HOST=${DB_HOST}
DB_PORT=3306
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

REDIS_HOST=${REDIS_HOST}
REDIS_PASSWORD=${REDIS_PASSWORD}
REDIS_PORT=6379
EOF
    
    # 生成应用密钥
    php artisan key:generate
    
    # 设置目录权限
    chown -R www-data:www-data storage bootstrap/cache
    
    # 创建初始化标记
    touch /var/www/html/initialized
    echo "Initial setup completed!"
fi

# 启动cron服务
echo "* * * * * php /var/www/html/artisan schedule:run" > /etc/cron.d/v2board
chmod 0644 /etc/cron.d/v2board
cron

# 启动Supervisor
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf

# 保持容器运行
tail -f /dev/null
