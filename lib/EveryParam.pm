package EveryParam;
use Mojo::Base 'Mojolicious::Controller';

#-------------------------------------
sub get_array_params {
#-------------------------------------
my($self, $c, $param_name) = @_;
            
return @{$c->every_param($param_name)};
}#---------------

#-------------------------------------
sub get_array_del {
#-------------------------------------
my($self, $c, $param_name) = @_;
            
return @{$c->every_param($param_name)};
}#---------------

#-------------------------------------
sub get_array_users_opt {
#-------------------------------------
my($self, $c, $param_name) = @_;
            
return @{$c->every_param($param_name)};
}#---------------

#-------------------------------------
sub get_array_sending_opt {
#-------------------------------------
my($self, $c, $param_name) = @_;
            
return @{$c->every_param($param_name)};
}#---------------

#--------------------------------
sub get_param_names {
#--------------------------------
my($self, $c) = @_;            
return @{$c->req->params->names};
}#---------
1;