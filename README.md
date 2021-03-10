# MornCat CMS
Web-application based [Mojolicious](https://mojolicious.org)

## Preparing

Some Perl modules that MornCat requires cannot be installed without certain compilation tools. You need install universal GNU Compiler Collection (gcc).

To install it in **Linux** type in terminale:

`$ sudo apt install build-essential`

Confirm your installation by checking for GCC version:
```
$ gcc --version
gcc (Ubuntu 7.2.0-18ubuntu2) 7.2.0
Copyright (C) 2017 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

**`'make'`** utility required to install some Perl modules is supplied with build-essential usually. Check make installatuin typing

`$ make --version`
in terminale.

If make is not installed type the following in a shell:

`$ sudo apt install make`

**`'gcc'`** and **`'make'`** for **Windows** you can find at:

https://sourceware.org/cygwin/

and

https://sourceforge.net/projects/gnuwin32/files/make/3.81/
respectively.

## Start
So, you need.

**1. Installed Perl interpreter** 

If you are Linux user, check installed Perl typing in terminal:

`$ perl -v`

If Perl is installed, you'll view in terminal:

```
This is perl 5, version 26, subversion 3 (v5.26.3) built for x86_64-linux
(with 1 registered patch, see perl -V for more detail)

Copyright 1987-2018, Larry Wall

Perl may be copied only under the terms of either the Artistic License or the
GNU General Public License, which may be found in the Perl 5 source kit.

Complete documentation for Perl, including FAQ lists, should be found on
this system using "man perl" or "perldoc perl".  If you have access to the
Internet, point your browser at http://www.perl.org/, the Perl Home Page.
```

If Perl is not installed on your OS Linux, you can install it from source: [https://www.cpan.org/src/README.html](https://www.cpan.org/src/README.html)

If you work on Windows, download installer from [here](http://strawberryperl.com/download/5.16.3.1/strawberry-perl-5.16.3.1-32bit.msi) (It's recommended 5.16 version because it is difficult to install **`Image::Magick`** module on the higher Perl version)

**2. Installed database server**

MornCat tested with [PostgreSQL](https://www.postgresql.org/about/news/postgresql-96-released-1703/) (version 9.6).

## Installation
Create directory where you want place your application. For example, type in terminal

-on Linux:
```
$ cd /home
$ /home# mkdir www
$ /home# cd www
$ /home/www# mkdir myapplication
```

-on Windows:
```
C:\Users\WindowsUser>cd\
C:\>mkdir myapplication
```

Unpack **`MorncCat`** archive in the newly created directory. And then type in command line:

```
$ /home/www# cd myapplication
$ /home/www/myapplication# cpan
$ cpan> install App::cpanminus
```

After installing module `App::cpanminus` type in command line:

```
$ cpan>exit
$ /home/www/myapplication# cpanm --installdeps .
```

>Pay attention, the point after **`'installdeps + space'`** must be certainly.

Next you need install `PerlMagick` module.

-on Linux (Ubuntu):

`$ sudo apt-get update`

`$ sudo apt-get install perlmagick`

-on Windows:

`C:\>ppm install Image-Magick`

So you can start development server for running application:

`$ /home/www/myapplication# morbo my_blog.pl`

Now you will see something like this message:

```
Server available at http://127.0.0.1:3000
DBI connect('database=yourdatabase;host=localhost','Username',...) failed: could not connect to server: Connection refused (0x0000274D/10061)
        Is the server running on host "localhost" (::1) and accepting
        TCP/IP connections on port 5432?
could not connect to server: Connection refused (0x0000274D/10061)
        Is the server running on host "localhost" (127.0.0.1) and accepting
        TCP/IP connections on port 5432? at lib/DB.pm line 75.
Get started at /dbaccess address
```
Don't panic. Just enter **`http://127.0.0.1:3000/dbaccess`** in address bar of your browser


More documentation see at [MornCat](https://mojoblog.me/documentation/for_users) site