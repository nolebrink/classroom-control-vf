class nginx::params {
  case $::osfamily {
    'redhat','debian' : {
      $package  = 'nginx'
      $owner    = 'root'
      $group    = 'root'
      $docroot  = '/var/www'
      $confdir  = '/etc/nginx'
      $blockdir = '/etc/nginx/conf.d'           
    }
    'windows' : {
      $package  = 'nginx-service'
      $owner    = 'Administrator'
      $group    = 'Administrators'
      $docroot  = 'C:/ProgramData/nginx/html'
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
}
