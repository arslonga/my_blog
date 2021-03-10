package Moj::Util;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(encode decode);
use Mojo::File;

#----------------------------------
sub spurt {
#----------------------------------
my($self, $content, $path) = @_;
Mojo::File->new($path)->spurt($content);
return 1;
}#-------------

#----------------------------------
sub slurp {
#----------------------------------
my($self, $path) = @_;
return Mojo::File->new($path)->slurp;
}#-------------

#----------------------------------
sub decode_Pg {
#----------------------------------
my($self, $string) = @_;
return $string;
}#-------------

#----------------------------------
sub decode_mysql {
#----------------------------------
my($self, $string) = @_;
return decode('utf8', $string);
}#-------------

#----------------------------------
sub encode_Pg {
#----------------------------------
my($self, $string) = @_;
return encode('utf8', $string);
}#-------------

#----------------------------------
sub encode_mysql {
#----------------------------------
my($self, $string) = @_;
return $string;
}#-------------

#----------------------------------
sub path {
#----------------------------------
use Cwd;
my $cwd = cwd();
my($self, $path) = @_;
return Mojo::File->new($cwd.'/'.$path);
}#-------------
1;