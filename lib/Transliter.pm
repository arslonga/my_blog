package Transliter;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------
sub transliter {
#---------------------------
my $self = shift;
my $arg;

if(@_){ ($arg) = @_; }

$arg = lc $arg;
$arg =~ tr/абвгдеєжзиіїйклмнопрстуфхцчшщюяьъэы«»`ґ/abvhdeegzyiijklmnoprstufxzcccuj__ey___g/;
$arg =~ s/[\W]+/\_/g;

return $arg;
}#----------------
1;