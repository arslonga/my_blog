package MyBlog::Login;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------
sub logged_in {
#---------------------------
my $self = shift;
my $table_access = $self->top_config->{'table'}->{'access'};
my $login = $self->menu->find( $table_access, ['admin'] )->list;
$self->session('admin') eq $login ? return $self->session('admin') : $self->redirect_to('admin');
}#-----------

#----------------------------
sub logout {
#----------------------------
my $self = shift;
$self->session(expires => 1);
$self->redirect_to('admin');
}#---------

#---------------------------
sub user_logged_in {
#---------------------------
my $self = shift;    
return $self->session('client') || !$self->redirect_to('/user.admin');
}#-----------
1;