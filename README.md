# Groom your app’s PHP environment with phpenv.

Use phpenv to pick a PHP version for your application and guarantee
that your development environment matches production. Put phpenv to
work with [Composer](https://getcomposer.org/) for painless PHP
upgrades and bulletproof deployments.

**Powerful in development.** Specify your app's PHP version once,
  in a single file. Keep all your teammates on the same page. No
  headaches running apps on different versions of PHP. Just Works™
  from the command line and with app servers. Override the PHP
  version anytime: just set an environment variable.

**Rock-solid in production.** Your application's executables are its
  interface with ops. With phpenv you'll never again need to `cd` in
  a cron job or Chef recipe to ensure you've selected the right
  runtime. The PHP version dependency lives in one place—your app—so
  upgrades and rollbacks are atomic, even when you switch versions.

**One thing well.** phpenv is concerned solely with switching PHP
  versions. It's simple and predictable. A rich plugin ecosystem lets
  you tailor it to suit your needs. Compile your own PHP versions, or
  use the [php-build][] plugin to automate the process.

This project was forked from [rbenv](https://github.com/rbenv/rbenv),
and modified for PHP.

## Table of Contents

* [How It Works](#how-it-works)
  * [Understanding PATH](#understanding-path)
  * [Understanding Shims](#understanding-shims)
  * [Choosing the PHP Version](#choosing-the-php-version)
  * [Locating the PHP Installation](#locating-the-php-installation)
* [Installation](#installation)
  * [Basic GitHub Checkout](#basic-github-checkout)
    * [Upgrading](#upgrading)
  * [How phpenv hooks into your shell](#how-phpenv-hooks-into-your-shell)
  * [Installing PHP Versions](#installing-php-versions)
  * [Uninstalling PHP Versions](#uninstalling-php-versions)
  * [Uninstalling phpenv](#uninstalling-phpenv)
* [Command Reference](#command-reference)
  * [phpenv local](#phpenv-local)
  * [phpenv global](#phpenv-global)
  * [phpenv shell](#phpenv-shell)
  * [phpenv versions](#phpenv-versions)
  * [phpenv version](#phpenv-version)
  * [phpenv rehash](#phpenv-rehash)
  * [phpenv which](#phpenv-which)
  * [phpenv whence](#phpenv-whence)
* [Environment variables](#environment-variables)
* [Development](#development)

## How It Works

At a high level, phpenv intercepts PHP commands using shim
executables injected into your `PATH`, determines which PHP version
has been specified by your application, and passes your commands
along to the correct PHP installation.

### Understanding PATH

When you run a command like `php` or `php-cgi`, your operating system
searches through a list of directories to find an executable file with
that name. This list of directories lives in an environment variable
called `PATH`, with each directory in the list separated by a colon:

    /usr/local/bin:/usr/bin:/bin

Directories in `PATH` are searched from left to right, so a matching
executable in a directory at the beginning of the list takes
precedence over another one at the end. In this example, the
`/usr/local/bin` directory will be searched first, then `/usr/bin`,
then `/bin`.

### Understanding Shims

phpenv works by inserting a directory of _shims_ at the front of your
`PATH`:

    ~/.phpenv/shims:/usr/local/bin:/usr/bin:/bin

Through a process called _rehashing_, phpenv maintains shims in that
directory to match every PHP command across every installed version
of PHP—`pear`, `pecl`, `php`, `php-cgi`, `phpdbg`, and so on.

Shims are lightweight executables that simply pass your command along
to phpenv. So with phpenv installed, when you run, say, `php-cgi`,
your operating system will do the following:

* Search your `PATH` for an executable file named `php-cgi`
* Find the phpenv shim named `php-cgi` at the beginning of your
  `PATH`
* Run the shim named `php-cgi`, which in turn passes the command
  along to phpenv

### Choosing the PHP Version

When you execute a shim, phpenv determines which PHP version to use by
reading it from the following sources, in this order:

1. The `PHPENV_VERSION` environment variable, if specified. You can
   use the [`phpenv shell`](#phpenv-shell) command to set this
   environment variable in your current shell session.

2. The first `.php-version` file found by searching the directory of
   the script you are executing and each of its parent directories
   until reaching the root of your filesystem.

3. The first `.php-version` file found by searching the current working
   directory and each of its parent directories until reaching the root of your
   filesystem. You can modify the `.php-version` file in the current working
   directory with the [`phpenv local`](#phpenv-local) command.

4. The global `~/.phpenv/version` file. You can modify this file
   using the [`phpenv global`](#phpenv-global) command. If the global
   version file is not present, phpenv assumes you want to use the
   "system" PHP—i.e. whatever version would be run if phpenv weren't
   in your path.

### Locating the PHP Installation

Once phpenv has determined which version of PHP your application has
specified, it passes the command along to the corresponding PHP
installation.

Each PHP version is installed into its own directory under
`~/.phpenv/versions`. For example, you might have these versions
installed:

* `~/.phpenv/versions/7.0.32/`
* `~/.phpenv/versions/7.1.23/`
* `~/.phpenv/versions/7.2.11/`

Version names to phpenv are simply the names of the directories in
`~/.phpenv/versions`.

## Installation

### Basic GitHub Checkout

This will get you going with the latest version of phpenv and make it
easy to fork and contribute any changes back upstream.

1. Check out phpenv into `~/.phpenv`.

    ~~~ sh
    $ git clone https://github.com/sptndc/phpenv.git ~/.phpenv
    ~~~

    Optionally, try to compile dynamic bash extension to speed up phpenv. Don't
    worry if it fails; phpenv will still work normally:

    ~~~
    $ cd ~/.phpenv && src/configure && make -C src
    ~~~

2. Add `~/.phpenv/bin` to your `$PATH` for access to the `phpenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu Desktop note**: Modify your `~/.bashrc` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Run `~/.phpenv/bin/phpenv init` for shell-specific instructions on
   how to initialize phpenv to enable shims and autocompletion.

4. Restart your shell so that PATH changes take effect. (Opening a new
   terminal tab will usually do it.) Now check if phpenv was set up:

    ~~~ sh
    $ type phpenv
    #=> "phpenv is a function"
    ~~~

5. _(Optional)_ Install [php-build][], which provides the
   `phpenv install` command that simplifies the process of
   [installing new PHP versions](#installing-php-versions).

#### Upgrading

If you've installed phpenv manually using git, you can upgrade your
installation to the cutting-edge version at any time.

~~~ sh
$ cd ~/.phpenv
$ git pull
~~~

To use a specific release of phpenv, check out the corresponding tag:

~~~ sh
$ cd ~/.phpenv
$ git fetch
$ git checkout v1.1.0
~~~

### How phpenv hooks into your shell

Skip this section unless you must know what every line in your shell
profile is doing.

`phpenv init` is the only command that crosses the line of loading
extra commands into your shell. Here's what `phpenv init` actually
does:

1. Sets up your shims path. This is the only requirement for phpenv
   to function properly. You can do this by hand by prepending
   `~/.phpenv/shims` to your `$PATH`.

2. Installs autocompletion. This is entirely optional but pretty
   useful. Sourcing `~/.phpenv/completions/phpenv.bash` will set that
   up. There is also a `~/.phpenv/completions/phpenv.zsh` for Zsh
   users.

3. Rehashes shims. From time to time you'll need to rebuild your
   shim files. Doing this automatically makes sure everything is up
   to date. You can always run `phpenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   phpenv and plugins to change variables in your current shell,
   making commands like `phpenv shell` possible. The sh dispatcher
   doesn't do anything crazy like override `cd` or hack your shell
   prompt, but if for some reason you need `phpenv` to be a real
   script rather than a shell function, you can safely skip it.

Run `phpenv init -` for yourself to see exactly what happens under
the hood.

### Installing PHP Versions

The `phpenv install` command doesn't ship with phpenv out of the box,
but is provided by the [php-build][] project. If you installed it
either as part of GitHub checkout process outlined above, you should
be able to:

~~~ sh
# list all available versions:
$ phpenv install -l

# install a PHP version:
$ phpenv install 7.2.11
~~~

Alternatively to the `install` command, you can download and compile
PHP manually as a subdirectory of `~/.phpenv/versions/`. An entry in
that directory can also be a symlink to a PHP version installed
elsewhere on the filesystem. phpenv doesn't care; it will simply
treat any entry in the `versions/` directory as a separate PHP
version.

### Uninstalling PHP Versions

As time goes on, PHP versions you install will accumulate in your
`~/.phpenv/versions` directory.

To remove old PHP versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a
particular PHP version with the `phpenv prefix` command, e.g. `phpenv
prefix 7.0.32`.

The [php-build][] plugin provides an `phpenv uninstall` command to
automate the removal process.

### Uninstalling phpenv

The simplicity of phpenv makes it easy to temporarily disable it, or
uninstall from the system.

1. To **disable** phpenv managing your PHP versions, simply remove
   the `phpenv init` line from your shell startup configuration. This
   will remove phpenv shims directory from PATH, and future
   invocations like `php` will execute the system PHP version, as
   before phpenv.

   `phpenv` will still be accessible on the command line, but your
   PHP apps won't be affected by version switching.

2. To completely **uninstall** phpenv, perform step (1) and then
   remove its root directory. This will **delete all PHP versions**
   that were installed under `` `phpenv root`/versions/ `` directory:

        rm -rf `phpenv root`

## Command Reference

Like `git`, the `phpenv` command delegates to subcommands based on
its first argument. The most common subcommands are:

### phpenv local

Sets a local application-specific PHP version by writing the version
name to a `.php-version` file in the current directory. This version
overrides the global version, and can be overridden itself by setting
the `PHPENV_VERSION` environment variable or with the `phpenv shell`
command.

    $ phpenv local 7.1.23

When run without a version number, `phpenv local` reports the
currently configured local version. You can also unset the local
version:

    $ phpenv local --unset

### phpenv global

Sets the global version of PHP to be used in all shells by writing
the version name to the `~/.phpenv/version` file. This version can be
overridden by an application-specific `.php-version` file, or by
setting the `PHPENV_VERSION` environment variable.

    $ phpenv global 7.2.11

The special version name `system` tells phpenv to use the system PHP
(detected by searching your `$PATH`).

When run without a version number, `phpenv global` reports the
currently configured global version.

### phpenv shell

Sets a shell-specific PHP version by setting the `PHPENV_VERSION`
environment variable in your shell. This version overrides
application-specific versions and the global version.

    $ phpenv shell 7.0.32

When run without a version number, `phpenv shell` reports the current
value of `PHPENV_VERSION`. You can also unset the shell version:

    $ phpenv shell --unset

Note that you'll need phpenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`PHPENV_VERSION` variable yourself:

    $ export PHPENV_VERSION=7.0.32

### phpenv versions

Lists all PHP versions known to phpenv, and shows an asterisk next to
the currently active version.

    $ phpenv versions
      7.0.32
      7.1.23
    * 7.2.11 (set by /YOUR-USERNAME/.phpenv/version)

### phpenv version

Displays the currently active PHP version, along with information on
how it was set.

    $ phpenv version
    7.0.32 (set by /YOUR-USERNAME/.phpenv/version)

### phpenv rehash

Installs shims for all PHP executables known to phpenv (i.e.,
`~/.phpenv/versions/*/bin/*`). Run this command after you install a
new version of PHP.

    $ phpenv rehash

### phpenv which

Displays the full path to the executable that phpenv will invoke when
you run the given command.

    $ phpenv which phpdbg
    /YOUR-USERNAME/.phpenv/versions/7.1.23/bin/phpdbg

### phpenv whence

Lists all PHP versions with the given command installed.

    $ phpenv whence php-cgi
    7.0.32
    7.1.23
    7.2.11

## Environment variables

You can affect how phpenv operates with the following settings:

name | default | description
-----|---------|------------
`PHPENV_VERSION` | | Specifies the PHP version to be used.<br>Also see [`phpenv shell`](#phpenv-shell)
`PHPENV_ROOT` | `~/.phpenv` | Defines the directory under which PHP versions and shims reside.<br>Also see `phpenv root`
`PHPENV_DEBUG` | | Outputs debug information.<br>Also as: `phpenv --debug <subcommand>`
`PHPENV_HOOK_PATH` | | Colon-separated list of paths searched for phpenv hooks.
`PHPENV_DIR` | `$PWD` | Directory to start searching for `.php-version` files.

## Development

The phpenv source code is [hosted on
GitHub](https://github.com/sptndc/phpenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Tests are executed using [Bats](https://github.com/sstephenson/bats):

    $ bats test
    $ bats test/<file>.bats

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/sptndc/phpenv/issues).


  [php-build]: https://github.com/sptndc/php-build#readme
