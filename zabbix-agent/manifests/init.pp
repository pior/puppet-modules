

class zabbix-agent {
    $zabbix_config_dir = "/etc/zabbix"
    $zabbix_agentd_conf = "$zabbix_config_dir/zabbix_agentd.conf"

    case $operatingsystem {
        centos: {
            yumrepo { "andrewfarley":
                descr => "Andrew Farley RPM Repository",
                baseurl => "http://repo.andrewfarley.com/centos/\$releasever/\$basearch/",
                enabled => "1",
                gpgcheck => "0";
            }

            package {
                "zabbix":
                    ensure => installed,
                    require => Yumrepo["andrewfarley"];
                "zabbix-agent":
                    ensure => installed,
                    require => Package["zabbix"];
            }

            service {
                "zabbix-agentd":
                    enable => true,
                    ensure => running,
                    hasstatus => true,
                    require => [Package["zabbix-agent"], File["/var/run/zabbix"]];
            }

            file { 
                "/var/run/zabbix":
                    ensure => directory,
                    owner => "zabbix",
                    group => "zabbix",
                    require => Package["zabbix-agent"];
            }

            file {
                $zabbix_config_dir:
                    ensure => directory,
                    owner => root,
                    group => root,
                    mode => 0755,
                    require => Package["zabbix-agent"];    

                $zabbix_agentd_conf:
                    owner => root,
                    group => root,
                    mode => 0644,
                    content => template("zabbix-agent/zabbix_agentd_conf_centos.erb"),
                    require => Package["zabbix-agent"],
                    notify => Service["zabbix-agentd"];
            }
        }

        debian, ubuntu: {
            package { "zabbix-agent":
                    ensure => installed,
            }
            
            service { "zabbix-agent":
                    enable => true,
                    ensure => running,
                    hasstatus => true,
                    require => Package["zabbix-agent"];
            }

            file { $zabbix_agentd_conf:
                    owner => root,
                    group => root,
                    mode => 0644,
                    content => template("zabbix-agent/zabbix_agentd_conf_ubuntu.erb"),
                    require => Package["zabbix-agent"],
                    notify => Service["zabbix-agent"];
            }
        }
    }
}
