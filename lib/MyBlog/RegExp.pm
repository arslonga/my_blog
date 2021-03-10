package MyBlog::RegExp;
use Mojo::Base -base;
#use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(encode decode);
use Transliter;
use strict;
use warnings;

#---------------------------
sub name_clean {
#---------------------------
my($self, $arg) = @_;

$arg =~ s/[\%\#&;\`\,\\|\*~<>^\[\]{}\$\n\r]+//g;
return $arg;
}#-------------

#---------------------------
sub title_clean {
#---------------------------
my($self, $arg) = @_;

$arg =~ s/[\%\#&;\`\\|\*~<>^\[\]{}\$\n\r]+//g;
return $arg;
}#-------------

#---------------------------
sub keyword_clean {
#---------------------------
my($self, $arg) = @_;

$arg =~ s/[\%\#&;\`\\|\*~<>^()\[\]{}\$\n\r]+//g;
return $arg;
}#-------------

#---------------------------
sub alias_clean {
#---------------------------
my($self, $arg) = @_;

$arg =~ s/[\%\#&;\`\,\.\\|\*~<>^()\[\]{}\$\n\r]+//g;
$arg =~s/\s+/\_/g ;

$arg = Transliter->transliter($arg);
return $arg;
}#-------------

#---------------------------
sub alias_clean_m {
#---------------------------
my($self, $c, $arg) = @_;

$arg =~ s/[\%\#&;\`\,\.\\|\*~<>^()\[\]{}\$\n\r]+//g;
$arg =~s/\s+/\_/g ;

my $salt = encode('latin-1', $arg);
if( $salt =~ /\W/g ){
return 'invalid';
}
return Transliter->transliter($arg);
}#-------------

#---------------------------
sub search_clean {
#---------------------------
my($self, $arg) = @_;

$arg =~s/\,\s+/ /g ;
$arg =~ s/\<[^<>]+\>//g;
$arg =~ s/\.+/\./g;
$arg =~ s/\/+/\//g;
$arg =~ s/[\’\'&;`"\\|*?~<>^()\[\]{}\$\n\r]+//g;
return $arg;
}#-------------

#---------------------------
sub email_clean {
#---------------------------
my($self, $c, $arg) = @_;
my $err;

$arg =~ s/[\’\'\%\#&;\:`\\|\*?~<>^()\[\]{}\$\n\r\s]+//g;

if( !($arg =~ /\@/) ){
    $err = 'Wrong symbols';
}
return($arg, $err);
}#-------------

#---------------------------
sub clean_email {
#---------------------------
my($self, $arg) = @_;
my $err;
$arg =~ s/[\n\r]+//g;

if( !($arg =~ /\@/) ){
    $err = {'email_err' => 'wrong_symbols_email'};
return($arg, $err);
}
if( $arg =~ /[^[:ascii:]]/g || $arg =~ /[\’\'\%\#&;\:`\\|\*?~<>^()\[\]{}\$\s]+/ ){
    $err = {'email_err' => 'not_allowed_characters_in_email'};
return($arg, $err);
}
return($arg, '');
}#-------------

#---------------------------
sub clean_login {
#---------------------------
my($self, $arg) = @_;
my $err;
$arg =~ s/[\n\r]+//g;
if( scalar( split(//, $arg) ) < 4 ){
    $err = {'login_err' => 'too_few_chars_login'};
return($arg, $err);
}
if( $arg =~ /[^[:ascii:]]/g || $arg =~ /[\’\'\%\#&;\:`\\|\*?~<>^()\[\]{}\-\$\s]+/ ){
    $err = {'login_err' => 'not_allowed_characters_in_login'};
return($arg, $err);
}
return($arg, '');
}#-------------

#---------------------------
sub clean_passw {
#---------------------------
my($self, $arg) = @_;
my $err;
$arg =~ s/[\n\r]+//g;
if( scalar( split(//, $arg) ) < 8 ){
    $err = {'passw_err' => 'too_few_chars'};
return($arg, $err);
}
if( scalar( split(//, $arg) ) > 18 ){
    $err = {'passw_err' => 'too_much_chars'};
return($arg, $err);
}
if( $arg =~ /[^[:ascii:]]/g || $arg =~ /[\’\'\%\#&;\:`\\|\*?~<>^()\[\]{}\-\$\s]+/ ){
    $err = {'passw_err' => 'not_allowed_characters_in_passw'};
return($arg, $err);
}
return($arg, '');
}#-------------

#---------------------------
sub correct_menu_input {
#---------------------------
my $self = shift;
my $c = shift;
}#-------------
1;
