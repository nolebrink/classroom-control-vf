class nginx (
  $docroot,
  ) {
  case $::osfamily {
    'redhat','debian' : {
      $package  = 'nginx'
      $owner    = 'root'
      $group    = 'root'
#      $docroot  = '/var/www'
      $confdir  = '/etc/nginx'
      $blockdir = '/etc/nginx/conf.d'           
    }
    'windows' : {
      $package  = 'nginx-service'
      $owner    = 'Administrator'
      $group    = 'Administrators'
#      $docroot  = 'C:/ProgramData/nginx/html'
      $confdir  = 'C:/ProgramData/nginx/conf'
      $blockdir = 'C:/ProgramData/nginx/conf.d' 
    }
    default   : {
      fail("Module ${module_name} is not supported on ${::osfamily}")
    }
  }

  case $::osfamily {
    'redhat': {
      $run_user = 'nginx'
    }
    'debian': {
      $run_user = 'www-data'
    }
    'windows': {
      $run_user = 'nobody'
    }
  }


  File {
    owner => $owner,
    group => $group,
    mode  => '0644',
  }

  package { $package:
    ensure => present,
  }

  file { $docroot:
    ensure  => directory,
    require => Package[$package],
  }

  file { "${docroot}/index.html":
    ensure => file,
    source => 'puppet:///modules/nginx/index.html',
  }

  file { "${confdir}/nginx.conf":
    ensure              => file,
    #source             => 'puppet:///modules/nginx/nginx.conf',
    content             => epp('nginx/nginx.conf.epp',
             {
               run_user => $run_user,
               confdir  => $confdir,
             }),
    require             => Package[$package],
  }

  file { "${blockdir}/default.conf":
    ensure  => file,
    #source  => 'puppet:///modules/nginx/default.conf',
    content => epp('nginx/default.conf.epp'),
    require => Package[$package],
  }

  service { 'nginx':
    ensure    => running,
    subscribe => File["${blockdir}/default.conf", "${confdir}/nginx.conf"],
  }
}
