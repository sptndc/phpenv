# Simple PHP Version Management: phpenv

phpenv lets you easily switch between multiple versions of PHP. It's
simple, unobtrusive, and follows the UNIX tradition of single-purpose
tools that do one thing well.

This project was forked from [rbenv](https://github.com/rbenv/rbenv),
and modified for PHP.

### phpenv _does…_

* Let you **change the default PHP version** on a per-user basis.
* Provide support for **per-project PHP versions**.
* Allow you to **override the PHP version** with an environment
  variable.

### In contrast with phpbrew, phpenv _does not…_

* **Depend on PHP itself.** phpenv was made from pure shell scripts.
    There is no bootstrap problem of PHP.
* **Need to be loaded into your shell.** Instead, phpenv's shim
    approach works by adding a directory to your `$PATH`.
* **Override shell commands like `cd`.** That's dangerous and
    error-prone.
* **Install PHP.** You can build and install PHP yourself, or use
    [php-build](https://github.com/sptndc/php-build) to
    automate the process.
* **Prompt you with warnings when you switch to a project.** Instead
    of executing arbitrary code, phpenv reads just the version name
    from each project. There's nothing to "trust."

## Table of Contents

   * [1 How It Works](#section_1)
   * [2 Installation](#section_2)
      * [2.1 Basic GitHub Checkout](#section_2.1)
         * [2.1.1 Upgrading](#section_2.1.1)
      * [2.2 Neckbeard Configuration](#section_2.2)
   * [3 Usage](#section_3)
      * [3.1 phpenv global](#section_3.1)
      * [3.2 phpenv local](#section_3.2)
      * [3.3 phpenv shell](#section_3.3)
      * [3.4 phpenv versions](#section_3.4)
      * [3.5 phpenv version](#section_3.5)
      * [3.6 phpenv rehash](#section_3.6)
      * [3.7 phpenv which](#section_3.7)
      * [3.8 phpenv whence](#section_3.8)
   * [4 Development](#section_4)
      * [4.1 License](#section_4.1)

## <a name="section_1"></a> 1 How It Works

phpenv operates on the per-user directory `~/.phpenv`. Version names in
phpenv correspond to subdirectories of `~/.phpenv/versions`. For
example, you might have `~/.phpenv/versions/7.0.32` and
`~/.phpenv/versions/7.2.11`.

Each version is a working tree with its own binaries, like
`~/.phpenv/versions/7.0.32/bin/php` and
`~/.phpenv/versions/7.2.11/bin/php`. phpenv makes _shim binaries_
for every such binary across all installed versions of PHP.

These shims are simple wrapper scripts that live in `~/.phpenv/shims`
and detect which PHP version you want to use. They insert the
directory for the selected version at the beginning of your `$PATH`
and then execute the corresponding binary.

Because of the simplicity of the shim approach, all you need to use
phpenv is `~/.phpenv/shims` in your `$PATH`.

## <a name="section_2"></a> 2 Installation

### <a name="section_2.1"></a> 2.1 Basic GitHub Checkout

This will get you going with the latest version of rbenv and make it
easy to fork and contribute any changes back upstream.

1. Check out phpenv into `~/.phpenv`.

        $ cd
        $ git clone git://github.com/sptndc/phpenv.git .phpenv

2. Add `~/.phpenv/bin` to your `$PATH` for access to the `phpenv`
   command-line utility.

        $ echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> ~/.bash_profile

    **Zsh note**: Modifiy your `~/.zshrc` file instead of `~/.bash_profile`.

3. Add phpenv init to your shell to enable shims and autocompletion.

        $ echo 'eval "$(phpenv init -)"' >> ~/.bash_profile

    **Zsh note**: Modifiy your `~/.zshrc` file instead of `~/.bash_profile`.

4. Restart your shell so the path changes take effect. You can now
   begin using phpenv.

        $ exec $SHELL

5. Install PHP versions into `~/.phpenv/versions`. For example, to
   install PHP 7.1.23, download and unpack the source, then run:

        $ ./configure --prefix=$HOME/.phpenv/versions/7.1.23
        $ make
        $ make install

   The [php-build](https://github.com/sptndc/php-build) project
   provides an `phpenv install` command that simplifies the process
   of installing new PHP versions to:

        $ phpenv install 7.1.23

6. Rebuild the shim binaries. You should do this any time you install
   a new PHP binary (for example, when installing a new PHP version).

        $ phpenv rehash

#### <a name="section_2.1.1"></a> 2.1.1 Upgrading

If you've installed phpenv using the instructions above, you can
upgrade your installation at any time using git.

To upgrade to the latest development version of phpenv, use `git pull`:

    $ cd ~/.phpenv
    $ git pull

To upgrade to a specific release of phpenv, check out the corresponding
tag:

    $ cd ~/.phpenv
    $ git fetch
    $ git tag
    v0.1.0
    v0.1.1
    v0.1.2
    v0.2.0
    $ git checkout v0.2.0

### <a name="section_2.2"></a> 2.2 Neckbeard Configuration

Skip this section unless you must know what every line in your shell
profile is doing.

`phpenv init` is the only command that crosses the line of loading
extra commands into your shell. Here's what `phpenv init` actually does:

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
   phpenv and plugins to change variables in your current shell, making
   commands like `phpenv shell` possible. The sh dispatcher doesn't do
   anything crazy like override `cd` or hack your shell prompt, but if
   for some reason you need `phpenv` to be a real script rather than a
   shell function, you can safely skip it.

Run `phpenv init -` for yourself to see exactly what happens under the
hood.

## <a name="section_3"></a> 3 Usage

Like `git`, the `phpenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### <a name="section_3.1"></a> 3.1 phpenv global

Sets the global version of PHP to be used in all shells by writing
the version name to the `~/.phpenv/version` file. This version can be
overridden by a per-project `.phpenv-version` file, or by setting the
`PHPENV_VERSION` environment variable.

    $ phpenv global 7.1.23

The special version name `system` tells phpenv to use the system PHP
(detected by searching your `$PATH`).

When run without a version number, `phpenv global` reports the
currently configured global version.

### <a name="section_3.2"></a> 3.2 phpenv local

Sets a local per-project PHP version by writing the version name to
an `.phpenv-version` file in the current directory. This version
overrides the global, and can be overridden itself by setting the
`PHPENV_VERSION` environment variable or with the `phpenv shell`
command.

    $ phpenv local 7.0.32

When run without a version number, `phpenv local` reports the
currently configured local version. You can also unset the local
version:

    $ phpenv local --unset

### <a name="section_3.3"></a> 3.3 phpenv shell

Sets a shell-specific PHP version by setting the `PHPENV_VERSION`
environment variable in your shell. This version overrides both
project-specific versions and the global version.

    $ phpenv shell 7.0.32

When run without a version number, `phpenv shell` reports the current
value of `PHPENV_VERSION`. You can also unset the shell version:

    $ phpenv shell --unset

Note that you'll need phpenv's shell integration enabled (step 3 of
the installation instructions) in order to use this command. If you
prefer not to use shell integration, you may simply set the
`PHPENV_VERSION` variable yourself:

    $ export PHPENV_VERSION=7.0.32

### <a name="section_3.4"></a> 3.4 phpenv versions

Lists all PHP versions known to phpenv, and shows an asterisk next to
the currently active version.

    $ phpenv versions
      7.0.23
      7.1.23
    * 7.2.11 (set by /YOUR-USERNAME/.phpenv/default)

### <a name="section_3.5"></a> 3.5 phpenv version

Displays the currently active PHP version, along with information on
how it was set.

    $ phpenv version
    7.0.32 (set by /YOUR-PROJECT/.phpenv-version)

### <a name="section_3.6"></a> 3.6 phpenv rehash

Installs shims for all PHP binaries known to phpenv (i.e.,
`~/.phpenv/versions/*/bin/*`). Run this command after you install a new
version of PHP.

    $ phpenv rehash

### <a name="section_3.7"></a> 3.7 phpenv which

Displays the full path to the binary that phpenv will execute when you
run the given command.

    $ phpenv which phpdbg
    /YOUR-USERNAME/.phpenv/versions/7.1.23/bin/phpdbg

### <a name="section_3.8"></a> 3.8 phpenv whence

Lists all PHP versions with the given command installed.

    $ phpenv whence php-cgi
    7.0.32
    7.1.23
    7.2.11

## <a name="section_4"></a> 4 Development

The phpenv source code is [hosted on
GitHub](https://github.com/sptndc/phpenv). It's clean, modular,
and easy to understand, even if you're not a shell hacker.

Please feel free to submit pull requests and file bugs on the [issue
tracker](https://github.com/sptndc/phpenv/issues).

### <a name="section_4.1"></a> 4.1 License

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
