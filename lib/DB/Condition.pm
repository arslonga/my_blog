package DB::Condition;
use base 'DB';
use Mojo::Base 'Mojolicious::Controller';

use strict;
use warnings;

#----------------------------------------------
sub new{
#----------------------------------------------
   my $proto = shift;
   my $class = ref($proto) || $proto;

   my $self = {};

   bless($self, $class);
return $self;
}#-------------

#----------------------------------------------
sub check {
#----------------------------------------------
my($self, $table) = @_;
return $self->db->query(qq[check table $table MEDIUM])->hashes;
}#---------------

#----------------------------------------------
sub repair {
#----------------------------------------------
my($self, $table) = @_;
return $self->db->query(qq[repair table $table EXTENDED])->hashes;
}#---------------
1;