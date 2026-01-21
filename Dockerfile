# Base image with PHP + FrankenPHP
FROM dunglas/frankenphp:1-php8.2

# Set working directory
WORKDIR /var/www/html

RUN apt-get update && apt-get install -y \
    git unzip curl libpq-dev libzip-dev zip nodejs npm \
    && docker-php-ext-install pdo pdo_mysql zip pcntl \
    && docker-php-ext-enable pcntl \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Composer globally
RUN curl -sS https://getcomposer.org/installer | php -- \
    --install-dir=/usr/local/bin --filename=composer

# Install latest stable Node via n
RUN npm install -g n && n 22.19.0

# Copy existing application
COPY . .

# Install Laravel dependencies
RUN composer install --no-dev --optimize-autoloader
RUN npm install && npm run build

RUN composer require laravel/octane
RUN php artisan octane:install --server=frankenphp

# Give permissions
RUN chmod -R 775 storage bootstrap/cache

RUN echo "memory_limit=512M" > /usr/local/etc/php/conf.d/memory-limit.ini

# Expose port for Octane
EXPOSE 8000

# Default command — Laravel Octane in FrankenPHP mode with watch (dev)
CMD ["php", "artisan", "octane:start", "--server=frankenphp", "--host=0.0.0.0", "--port=8000", "--watch"]
