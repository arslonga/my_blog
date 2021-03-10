package RewrMenu;
use Mojo::Base 'Mojolicious::Controller';

#----------------------------------
sub active_rewrite {
#----------------------------------
my($c, $self) = @_;
my $menu = $self->menu->find('level0', ['menu'], {'url' => '/'})->list;
$menu =~ s/\s+class\=\"activ\"//;

return $menu;
}#-------------
1;