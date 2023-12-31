# Use an official PHP image as the base image
FROM php:7.4-apache

# Set environment variables for FreshRSS
ENV FRESHRSS_VERSION 1.17.0
ENV FRESHRSS_ROOT /var/www/html
ENV FRESHRSS_INSTALL_DIR /var/www/html

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    zlib1g-dev \
    libzip-dev \
    libicu-dev \
    wget \
    unzip \
    git \
    && docker-php-ext-install pdo pdo_mysql zip intl

# Download and extract FreshRSS
RUN mkdir -p ${FRESHRSS_ROOT} && \
    cd ${FRESHRSS_ROOT} && \
    curl -L -o freshrss.tar.gz https://github.com/FreshRSS/FreshRSS/archive/${FRESHRSS_VERSION}.tar.gz && \
    tar -xzvf freshrss.tar.gz --strip-components=1 && \
    rm freshrss.tar.gz

# Change ownership and set permissions for the ./data directory
RUN chown -R www-data:www-data /var/www/html/data && \
    chmod -R 775 /var/www/html/data

# Enable Apache modules
RUN a2enmod rewrite

# Configure Apache
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80

# Download the xExtension-CustomCSS extension from GitHub
RUN wget https://github.com/FreshRSS/Extensions/archive/master.zip && \
    unzip master.zip && \
    mv Extensions-master/* /var/www/html/extensions/ && \
    rm -rf master.zip Extensions-master

# Change permissions for the extensions directory and its folders
RUN chown -R www-data:www-data /var/www/html/extensions/ && \
    chmod -R 775 /var/www/html/extensions/ && \
    chown -R www-data:www-data /var/www/html/extensions && \
    chmod -R 775 /var/www/html/extensions
    
# Change directory to the FreshRSS themes directory and clone the "freshrss-nord-theme" repository
RUN cd "${FRESHRSS_INSTALL_DIR}/p/themes" && \
    git clone https://github.com/joelchrono12/freshrss-nord-theme.git


# Start Apache
CMD ["apache2-foreground"]
