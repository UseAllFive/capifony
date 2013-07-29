namespace :symfony do
  namespace :composer do
    desc "Gets composer and installs it"
    task :get, :roles => :app, :except => { :no_release => true } do
      if use_composer_tmp
        # Because we always install to temp location we assume that we download composer every time.
        logger.debug "Downloading composer to #{$temp_destination}"
        capifony_pretty_print "--> Downloading Composer to temp location"
        run_locally "cd #{$temp_destination} && curl -s http://getcomposer.org/installer | #{php_bin}"
      else
        if !remote_file_exists?("#{latest_release}/composer.phar")
          capifony_pretty_print "--> Downloading Composer"

          run "#{try_sudo} sh -c 'cd #{latest_release} && curl -s http://getcomposer.org/installer | #{php_bin}'"
        else
          capifony_pretty_print "--> Updating Composer"

          run "#{try_sudo} sh -c 'cd #{latest_release} && #{php_bin} composer.phar self-update'"
        end
      end
      capifony_puts_ok
    end

    desc "Updates composer"

    desc "Runs composer to install vendors from composer.lock file"
    task :install, :roles => :app, :except => { :no_release => true } do

      if !composer_bin
        symfony.composer.get
        set :composer_bin, "#{php_bin} composer.phar"
      end

      options = "#{composer_options}"
      if !interactive_mode
        options += " --no-interaction"
      end

      if use_composer_tmp
        logger.debug "Installing composer dependencies to #{$temp_destination}"
        capifony_pretty_print "--> Installing Composer dependencies in temp location"
        run_locally "cd #{$temp_destination} && SYMFONY_ENV=#{symfony_env_prod} #{composer_bin} install #{options}"
        capifony_puts_ok
      else
        capifony_pretty_print "--> Installing Composer dependencies"
        run "#{try_sudo} sh -c 'cd #{latest_release} && SYMFONY_ENV=#{symfony_env_prod} #{composer_bin} install #{options}'"
        capifony_puts_ok
      end
    end

    desc "Runs composer to update vendors, and composer.lock file"
    task :update, :roles => :app, :except => { :no_release => true } do
      if !composer_bin
        symfony.composer.get
        set :composer_bin, "#{php_bin} composer.phar"
      end

      options = "#{composer_options}"
      if !interactive_mode
        options += " --no-interaction"
      end

      capifony_pretty_print "--> Updating Composer dependencies"
      run "#{try_sudo} sh -c 'cd #{latest_release} && #{composer_bin} update #{options}'"
      capifony_puts_ok
    end

    desc "Dumps an optimized autoloader"
    task :dump_autoload, :roles => :app, :except => { :no_release => true } do
      if !composer_bin
        symfony.composer.get
        set :composer_bin, "#{php_bin} composer.phar"
      end

      capifony_pretty_print "--> Dumping an optimized autoloader"
      run "#{try_sudo} sh -c 'cd #{latest_release} && #{composer_bin} dump-autoload --optimize'"
      capifony_puts_ok
    end

    task :copy_vendors, :except => { :no_release => true } do
      capifony_pretty_print "--> Copying vendors from previous release"

      run "vendorDir=#{current_path}/vendor; if [ -d $vendorDir ] || [ -h $vendorDir ]; then cp -a $vendorDir #{latest_release}/vendor; fi;"
      capifony_puts_ok
    end

    # Install composer to temp directory.
    # Not sure if this is required yet.
    desc "Dumps an optimized autoloader"
    task :dump_autoload_temp, :roles => :app, :except => { :no_release => true } do
      if !composer_bin
        symfony.composer.get_temp
        set :composer_bin, "#{php_bin} composer.phar"
      end

      logger.debug "Dumping an optimised autoloader to #{$temp_destination}"
      capifony_pretty_print "--> Dumping an optimized autoloader to temp location"
      run_locally cd "#{$temp_destination} && #{composer_bin} dump-autoload --optimize"
      capifony_puts_ok
    end

  end
end
