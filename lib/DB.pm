package DB;
use Mojo::Base 'Mojolicious::Controller';

use strict;
use warnings;
use DBIx::Simple;
use SQL::Abstract;
use DB::Table;
use DB::Select;
use DB::Creat;
use DB::Insert;
use Carp qw/croak/;

my $db;
#-------------------------------------------------------
sub connect_db{
#-------------------------------------------------------
my($self, $c, $ref_need_tables) = @_;

my($dbh,  $err);

my $connect_action = 'connect_'.$c->db_driver;
return $c->redirect_to('/dbdriver') if(!$c->db_driver);

eval{
($dbh, $err) = $self->$connect_action( $c );
};

say "Get started at /dbaccess address" if $err;
return ($dbh, $err) if $err;

#$dbh->{lc($c->db_driver).'_enable_utf8'} = 1;
$dbh->do("set names 'utf8'");
#$dbh->do("set names 'cp1251'");

$db = DBIx::Simple->connect($dbh);
return $db;
} #-------------

#----------------------------------
sub db {
#----------------------------------
    return $db if $db;
    croak "You should init model first!";
}#----------

#----------------------------------
sub connect_Pg {
#----------------------------------
my($self, $c) = @_;
my( $dbh, $err, $scheme, $driver, $attr_string, $attr_hash, $driver_dsn );

eval{
($scheme, 
 $driver, 
 $attr_string, 
 $attr_hash, 
 $driver_dsn) = DBI->parse_dsn("dbi:Pg:".$c->dbconfig->{'database'}.":".$c->dbconfig->{'host'});
};
return unless scalar(split(/\:/, $driver_dsn)) >=2;

eval{
$dbh = DBI->connect( 'dbi:Pg:database='.
                     $c->dbconfig->{'database'}.
                     ';host='.
                     $c->dbconfig->{'host'}, 
                     $c->dbconfig->{'username'}, 
                     $c->dbconfig->{'password'} ); #,{AutoCommit=>1,RaiseError=>0,PrintError=>1} ); # or die "Can't connect: $DBI::errstr\n"; #,{AutoCommit=>1,RaiseError=>0,PrintError=>1} );
};
$err = $DBI::errstr;
return ($dbh, $err);
}#----------

#----------------------------------
sub connect_mysql {
#----------------------------------
my($self, $c) = @_;
my( $dbh, $err, $scheme, $driver, $attr_string, $attr_hash, $driver_dsn );

eval{
($scheme, 
 $driver, 
 $attr_string, 
 $attr_hash, 
 $driver_dsn) = DBI->parse_dsn("DBI:mysql:".$c->dbconfig->{'database'}.":".$c->dbconfig->{'host'});
};
return unless scalar(split(/\:/, $driver_dsn)) >=2;

eval{
$dbh = DBI->connect( 'DBI:mysql:database='.
                     $c->dbconfig->{'database'}.
                     ';host='.
                     $c->dbconfig->{'host'}, 
                     $c->dbconfig->{'username'},
                     $c->dbconfig->{'password'} 
                   );
};
$err = $DBI::errstr;
return ($dbh, $err);
}#----------
1;
