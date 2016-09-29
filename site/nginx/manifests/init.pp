class nginx (
  $package  = $nginx::params::package,
  $owner    = $nginx::params::owner,
  $group    = $nginx::params::group,
  $docroot  = $nginx::params::docroot,
  $confdir  = $nginx::params::confdir,
  $blockdir = $nginx::params::blockdir,
  ) inherits nginx::params {

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
    content             => epp('nginx/nginx_conf.epp',
             {
               run_user => $run_user,
               confdir  => $confdir,
               blockdir => $blockdir,
               confdir  => $confdir,
             }),
    require             => Package[$package],
  }

  file { "${blockdir}/default.conf":
    ensure  => file,
    #source  => 'puppet:///modules/nginx/default.conf',
    content => epp('nginx/default_conf.epp',
            {
              docroot  => $docroot,
              }),
    require            => Package[$package],
  }

  service { 'nginx':
    ensure    => running,
    subscribe => File["${blockdir}/default.conf", "${confdir}/nginx.conf"],
  }
}
