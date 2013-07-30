# Cookbook Name:: nova-network
# Recipe:: quantum-brocade-plugin
#
# Copyright 2012, Rackspace US, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe "osops-utils"
include_recipe "nova-network::quantum-common"

platform_options = node["quantum"]["platform"]
plugin = node["quantum"]["plugin"]


node["quantum"][plugin]["packages"].each do |pkg|
  package pkg do
    action node["osops"]["do_package_upgrades"] == true ? :upgrade : :install
    options platform_options["package_overrides"]
  end
end

# Brocade plugin uses the linux bridge agent
service "quantum-plugin-linuxbridge-agent" do
  service_name node["quantum"]["brocade"]["service_name"]
  supports :status => true, :restart => true
  action :enable
  subscribes :restart, "template[/etc/quantum/quantum.conf]", :delayed
  subscribes :restart, "template[/etc/quantum/plugins/brocade/brocade.ini]", :delayed
end

template "/etc/init/quantum-plugin-linuxbridge-agent.conf" do
	source "quantum-plugin-linuxbridge-agent.conf.erb"
	owner "root"
	group "root"
	mode "0644"
	variables(
		# jeff: add attributes for choosing ini files
	)
end
