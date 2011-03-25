
class pdns-recursor {
	$pdnsrecursor_bind = "0.0.0.0"	
	$pdnsrecursor_allow = "127.0.0.0/8, 10.0.0.0/8, 69.28.213.0/25"	
	include pdns-recursor::base
}

class pdns-recursor::local {
	$pdnsrecursor_bind = "127.0.0.1"	
	$pdnsrecursor_allow = "127.0.0.0/8"	
	include pdns-recursor::base
}

class pdns-recursor::base {

	package {
		"pdns-recursor.$architecture": 
			ensure => "installed",
	}

	file {
		"/etc/pdns-recursor/recursor.conf":
			content => template("pdns-recursor/recursor.conf.erb"),
			mode => "644",
			require => Package["pdns-recursor.$architecture"],
	}	

	service { "pdns-recursor":
		enable  => true,
       		ensure  => running,
		hasstatus => true,
       		require => Package["pdns-recursor.$architecture"],
       		subscribe => File["/etc/pdns-recursor/recursor.conf"],
	}

}
