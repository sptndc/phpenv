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
  use the [php-build](https://github.com/sptndc/php-build) plugin to
  automate the process.

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
  * [Neckbeard Configuration](#neckbeard-configuration)
  * [Uninstalling PHP Versions](#uninstalling-php-versions)
* [Command Reference](#command-reference)
  * [phpenv local](#phpenv-local)
  * [phpenv global](#phpenv-global)
  * [phpenv shell](#phpenv-shell)
  * [phpenv versions](#phpenv-versions)
  * [phpenv version](#phpenv-version)
  * [phpenv rehash](#phpenv-rehash)
  * [phpenv which](#phpenv-which)
  * [phpenv whence](#phpenv-whence)
* [Development](#development)
  * [License](#license)

## How It Works

At high level, phpenv intercepts PHP commands using shim executables
injected into your `PATH`, determines which PHP version has been
specified by your application, and passes your commands along to the
correct PHP installation.

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

2. The application-specific `.php-version` file in the current
   directory, if present. You can modify the current directory's
   `.php-version` file with the [`phpenv local`](#phpenv-local)
   command.

3. The first `.php-version` file found by searching each parent
   directory until reaching the root of your filesystem, if any.

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
    $ git clone git://github.com/sptndc/phpenv.git ~/.phpenv
    ~~~

2. Add `~/.phpenv/bin` to your `$PATH` for access to the `phpenv`
   command-line utility.

    ~~~ sh
    $ echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bash_profile
    ~~~

    **Ubuntu note**: Modify your `~/.profile` instead of `~/.bash_profile`.

    **Zsh note**: Modify your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add `phpenv init` to your shell to enable shims and autocompletion.

    ~~~ sh
    $ echo 'eval "$(phpenv init -)"' >> ~/.bash_profile
    ~~~

    _Same as in previous step, use `~/.profile` on Ubuntu, `~/.zshrc` for zsh._

4. Restart your shell as a login shell so the path changes take effect.
   You can now begin using rbenv.

    ~~~ sh
    $ exec $SHELL -l
    ~~~

5. Install [php-build](https://github.com/sptndc/php-build),
   which provides an `phpenv install` command that simplifies the
   process of installing new PHP versions.

    ~~~ sh
    $ phpenv install 7.2.11
    ~~~

   As an alternative, you can download and compile PHP yourself into
   `~/.phpenv/versions/`.

6. Rebuild the shim executables. You should do this any time you
   install a new PHP executable (for example, when installing a new
   PHP version).

    ~~~ sh
    $ rbenv rehash
    ~~~

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
$ git checkout v0.3.0
~~~

### Neckbeard Configuration

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
   shim files. Doing this on init makes sure everything is up to
   date. You can always run `phpenv rehash` manually.

4. Installs the sh dispatcher. This bit is also optional, but allows
   phpenv and plugins to change variables in your current shell,
   making commands like `phpenv shell` possible. The sh dispatcher
   doesn't do anything crazy like override `cd` or hack your shell
   prompt, but if for some reason you need `phpenv` to be a real
   script rather than a shell function, you can safely skip it.

Run `phpenv init -` for yourself to see exactly what happens under
the hood.

### Uninstalling PHP Versions

As time goes on, PHP versions you install will accumulate in your
`~/.phpenv/versions` directory.

To remove old PHP versions, simply `rm -rf` the directory of the
version you want to remove. You can find the directory of a
particular PHP version with the `phpenv prefix` command, e.g. `phpenv
prefix 7.0.32`.

The [php-build](https://github.com/sptndc/php-build) plugin
provides an `phpenv uninstall` command to automate the removal
process.

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

Previous versions of phpenv stored local version specifications in a
file named `.phpenv-version`. For backwards compatibility, phpenv
will read a local version specified in an `.phpenv-version` file, but
a `.php-version` file in the same directory will take precedence.

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
    7.0.32 (set by /YOUR-PROJECT/.php-version)

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

## Development

The phpenv source code is [hosted on
GitHub](https://github.com/sptndc/phpenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/sptndc/phpenv/issues).

### License

(The MIT license)

Copyright (c) 2018 Septian Dwic.\
Copyright (c) 2011-2013 Sam Stephenson

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
