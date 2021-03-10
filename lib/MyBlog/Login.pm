package MyBlog::Login;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------
sub logged_in {
#---------------------------
my $self = shift;
my $table_access = $self->top_config->{'table'}->{'access'};
my $access_row = $self->menu->find($table_access, '*')->hash;
my $login   = $access_row->{admin};
my $passwrd = $access_row->{password};

$self->session('admin')->[0] eq $login && $self->session('admin')->[1] eq $passwrd ? return $self->session('admin') : $self->redirect_to('admin');
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