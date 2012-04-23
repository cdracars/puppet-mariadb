class mariadb::install {

    case $::operatingsystem {

        'centos': {

               $basearch = "i386"
               yumrepo {

               "ourdelta":
                        descr       => "Ourdelta",
                        enabled     => 1,
                        gpgcheck    => 0,
                        baseurl     => "http://master.ourdelta.org/yum/CentOS-MySQL50/5Server/"; 
                
                }

                package { "MySQL-OurDelta-server.$basearch":
                    alias  => "MySQL-server",
                    ensure => "installed";
                }

                package { "MySQL-OurDelta-client.$basearch":
                    alias  => "MySQL-client",
                    ensure => "installed";
                }
                    
            }

        'debian': {

            exec { "Import Key":
                command => "/usr/bin/apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 1BB943DB && /usr/bin/touch /root/.my.keyimported",
                creates => "/root/.my.keyimported";
            }

            file { "/etc/apt/sources.list.d/maria.list":	
                content => "# MariaDB repository list - created 2011-07-05 07:31 UTC
                # http://downloads.askmonty.org/mariadb/repositories/
                deb http://mirror.switch.ch/mirror/mariadb/repo/5.2/debian squeeze main
                deb-src http://mirror.switch.ch/mirror/mariadb/repo/5.2/debian squeeze main",
                require => Exec["Import Key"];
	        }
    
            package { "mariadb-server":
                ensure => "installed",
                require => [ File["/etc/apt/sources.list.d/maria.list"], Exec["apt-update"] ];
            }

            package { "mariadb-client":
                ensure => "installed",
                require => [ File["/etc/apt/sources.list.d/maria.list"], Exec["apt-update"] ];
            }		

            Exec["Import Key"] -> File["/etc/apt/sources.list.d/maria.list"] -> Exec["apt-update"] -> Package["mariadb-server"] -> Package["mariadb-client"]

	    }

        default: { fail("No such operatingsystem: ${::operatingsystem} yet defined") }

    }

}
