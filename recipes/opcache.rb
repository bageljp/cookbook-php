#
# Cookbook Name:: php
# Recipe:: opcache
#
# Copyright 2014, bageljp
#
# All rights reserved - Do Not Redistribute
#

case node['platform']
when "amazon"
  package "php55-opcache"
when "redhat","centos"
  case node['php']['version']['major']
  when '5.5'
    case node['php']['install_flavor']
    when 'yum'
      %w(
        php55u-opcache
      ).each do |pkg|
        package pkg do
          action :install
          options "--enablerepo=ius"
        end
      end
    when 'rpm'
      rpms = [
        "php55u-opcache"
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
          rpm -Uvh #{rpms_join_pkg}
        EOC
        not_if "rpm -q #{rpms_join} > /dev/null 2>&1"
      end
    end
  end
end
