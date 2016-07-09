#
# Cookbook Name:: php
# Recipe:: fpm
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node['platform']
when 'amazon'
  case node['php']['version']['major']
  when '5.5'
    %w(
      php55-fpm
    ).each do |pkg|
      package pkg do
        action :install
      end
    end

    %w(
      php-5.5.ini
      php-fpm-5.5.conf
      php-fpm-5.5.d/php-fpm.conf
      php-fpm-5.5.d/www.conf
    ).each do |t|
      template "/etc/#{t}" do
        owner "root"
        group "root"
        mode 00644
        source "#{t}.erb"
        notifies :restart, "service[php-fpm-#{node['php']['version']['major']}]"
      end
    end

    template "/etc/logrotate.d/php-fpm-#{node['php']['version']['major']}" do
      owner "root"
      group "root"
      mode 00644
      source "logrotate.php-fpm-#{node['php']['version']['major']}.erb"
    end

    directory "/var/log/php-fpm/#{node['php']['version']['major']}" do
      owner "#{node['php']['fpm']['user']}"
      group "root"
      mode 00770
    end

    file "/var/log/php-fpm/#{node['php']['version']['major']}/www-error.log" do
      owner "#{node['php']['fpm']['user']}"
      group "#{node['php']['fpm']['group']}"
       mode 00644
    end

    service "php-fpm-#{node['php']['version']['major']}" do
      supports :status => true, :restart => true, :reload => true
      action [ :enable, :start ]
    end
  end
end
