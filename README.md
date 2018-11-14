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
* **Override shell commands like `cd`.** That's just obnoxious!
* **Install PHP.** You can build and install PHP yourself, or use
    [php-build](https://github.com/sptndc/php-build) to
    automate the process.
* **Prompt you with warnings when you switch to a project.** Instead
    of executing arbitrary code, phpenv reads just the version name
    from each project. There's nothing to "trust."

## Table of Contents

   * [1 How It Works](#section_1)
   * [2 Installation](#section_2)
   * [3 Usage](#section_3)
      * [3.1 set-default](#section_3.1)
      * [3.2 set-local](#section_3.2)
      * [3.3 versions](#section_3.3)
      * [3.4 version](#section_3.4)
      * [3.5 rehash](#section_3.5)
   * [4 Contributing](#section_4)
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

phpenv is a young project, so for now you must install it from source.

1. Check out phpenv into `~/.phpenv`.

        $ cd
        $ git clone git://github.com/sptndc/phpenv.git .phpenv

2. Add `~/.phpenv/bin` to your `$PATH` for access to the `phpenv`
   command-line utility.

        $ echo 'export PATH="$HOME/.phpenv/bin:$PATH"' >> .bash_profile

3. Add phpenv's shims directory to your `$PATH` and set up Bash
   autocompletion. (If you prefer not to load phpenv in your shell, you
   can manually add `$HOME/.phpenv/shims` to your path in step 2.)

        $ echo 'eval "$(phpenv init -)"' >> .bash_profile

4. Restart your shell. You can now begin using phpenv.

        $ exec

5. Install PHP versions into `~/.phpenv/versions`. For example, to
   install PHP 7.1.23, download and unpack the source, then run:

        $ ./configure --prefix=~/.phpenv/versions/7.1.23
        $ make
        $ make install

    The [php-build](https://github.com/sptndc/php-build)
    project simplifies this process to a single command:

        $ php-build 7.1.23 ~/.phpenv/versions/7.1.23

6. Rebuild the shim binaries. You should do this any time you install
   a new PHP binary (for example, when installing a new PHP version).

        $ phpenv rehash

## <a name="section_3"></a> 3 Usage

Like `git`, the `phpenv` command delegates to subcommands based on its
first argument. The most common subcommands are:

### <a name="section_3.1"></a> 3.1 set-default

Sets the default version of PHP to be used in all shells by writing
the version name to the `~/.phpenv/default` file. This version can be
overridden by a per-project `.phpenv-version` file, or by setting the
`PHPENV_VERSION` environment variable.

    $ phpenv set-default 7.1.23

The special version name `system` tells phpenv to use the system PHP
(detected by searching your `$PATH`).

### <a name="section_3.2"></a> 3.2 set-local

Sets a local per-project PHP version by writing the version name to
an `.phpenv-version` file in the current directory. This version
overrides the default, and can be overridden itself by setting the
`PHPENV_VERSION` environment variable.

    $ phpenv set-local 7.0.32

### <a name="section_3.3"></a> 3.3 versions

Lists all PHP versions known to phpenv, and shows an asterisk next to
the currently active version.

    $ phpenv versions
      7.0.23
      7.1.23
    * 7.2.11 (set by /YOUR-USERNAME/.phpenv/default)

### <a name="section_3.4"></a> 3.4 version

Displays the currently active PHP version, along with information on
how it was set.

    $ phpenv version
    7.0.32 (set by /YOUR-PROJECT/.phpenv-version)

### <a name="section_3.5"></a> 3.5 rehash

Installs shims for all PHP binaries known to phpenv (i.e.,
`~/.phpenv/versions/*/bin/*`). Run this command after you install a new
version of PHP.

    $ phpenv rehash

## <a name="section_4"></a> 4 Contributing

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
