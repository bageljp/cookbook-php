#
# Cookbook Name:: php
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

case node['platform']
when "amazon"
  case node['php']['version']['major']
  when '5.5'
    %w(
      php55
      php55-devel
      php55-mbstring
      php55-mysqlnd
    ).each do |pkg|
      package pkg do
        action :install
      end
    end

    template "/etc/php-#{node['php']['version']['major']}.ini" do
      owner "root"
      group "root"
      mode 00644
      source "php-#{node['php']['version']['major']}.ini.erb"
      unless node['php']['webserver'].nil?
        notifies :restart, "service[#{node['php']['webserver']}]"
      end
    end
  end
when "redhat","centos"
  include_recipe "yum-ius::default"

  case node['php']['version']['major']
  when '5.5'
    case node['php']['install_flavor']
    when 'yum'
      %w(
        php55u
        php55u-devel
        php55u-mbstring
        php55u-mysqlnd
      ).each do |pkg|
        package pkg do
          action :install
          options "--enablerepo=ius"
        end
      end
    when 'rpm'
      %w(
        pcre-devel
        libXpm-devel
        libxslt
        libxslt-devel
      ).each do |pkg|
        package pkg
      end

      case node['platform']
      when "redhat"
        %w(
          t1lib
          libvpx
        ).each do |pkg|
          package pkg
        end
      when "centos"
        %w(
          t1lib-devel
          libvpx-devel
        ).each do |pkg|
          package pkg
        end
      end

      rpms = [
        "php55u",
        "php55u-cli",
        "php55u-common",
        "php55u-devel",
        "php55u-gd",
        "php55u-mbstring",
        "php55u-pdo",
        "php55u-mysqlnd",
        "php55u-process",
        "php55u-xml"
      ]
      rpms.each do |pkg|
        remote_file "/usr/local/src/#{pkg}-#{node['php']['version']['major']}.#{node['php']['version']['minor']}-1.ius.el6.x86_64.rpm" do
          owner "root"
          group "root"
          mode 00644
          source "#{node['php']['rpm']['url']}#{pkg}-#{node['php']['version']['major']}.#{node['php']['version']['minor']}-1.ius.el6.x86_64.rpm"
        end
      end

      rpms_join = rpms.join(" ")
      rpms_join_pkg = ""
      rpms.each do |pkg|
        rpms_join_pkg += "#{pkg}-#{node['php']['version']['major']}.#{node['php']['version']['minor']}-1.ius.el6.x86_64.rpm "
      end
      bash "install php" do
        user "root"
        cwd "/usr/local/src"
        code <<-EOC
          yumdownloader php55u-pear php55u-pecl-jsonc php55u-pecl-jsonc-devel --enablerepo=ius
          rpm -Uvh #{rpms_join_pkg} php55u-pear-*.rpm php55u-pecl-jsonc-*.rpm php55u-pecl-jsonc-devel-*.rpm
        EOC
        not_if "rpm -q #{rpms_join} php55u-pear php55u-pecl-jsonc php55u-pecl-jsonc-devel > /dev/null 2>&1"
      end
    end

    template "/etc/php.ini" do
      owner "root"
      group "root"
      mode 00644
      source "php-#{node['php']['version']['major']}.ini.erb"
      unless node['php']['webserver'].nil?
        notifies :restart, "service[#{node['php']['webserver']}]"
      end
    end
  end
end
