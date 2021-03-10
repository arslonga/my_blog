#!/usr/bin/env perl

use strict;
use warnings;
use lib './lib';

use FindBin;
BEGIN { unshift @INC, "$FindBin::Bin/../lib" }

# Start command line interface for application
require Mojolicious::Commands;
Mojolicious::Commands->start_app('MyBlog');