package Session;
use Mojo::Base 'Mojolicious::Controller';

#-------------------------------------
sub user {
#-------------------------------------
my($self, $c, $id, $login, $email, $password) = @_;

$c->session( client => [$id, $login, $email, $password ], expiration => 32000000);

return 1;
}#---------------

#-------------------------------------
sub comment {
#-------------------------------------
my($self, $c, $user_id_name, $comment_id) = @_;
$c->session( $user_id_name => $comment_id, expiration => 32000000);

return 1;
}#---------------

#-------------------------------------
sub voting {
#-------------------------------------
my($self, $c, $user_vote_id, $title_alias_and_id) = @_;
$c->cookie( $user_vote_id => $title_alias_and_id, {expires => time + 32000000});

return 1;
}#---------------

#-------------------------------------
sub added_comment {
#-------------------------------------
my($self, $c, $comment_id) = @_;
$c->cookie('added_comment' => $comment_id, {expires => time + 10});

return 1;
}#---------------

#-------------------------------------
sub admin {
#-------------------------------------
my($self, $c, $login) = @_;
$c->session( admin => $login, expiration => 32000000 );
return 1;
}#---------------

#-------------------------------------
sub admin_expire {
#-------------------------------------
my($self, $c, $login) = @_;
delete $c->session->{'admin'};
return 1;
}#---------------

#-------------------------------------
sub _client_expire {
#-------------------------------------
my($self, $c) = @_;

$c->session( client => [ $c->session('client')->[1] ], expires => 1);

return 1;
}#---------------

#-------------------------------------
sub client_expire {
#-------------------------------------
my($self, $c, $id) = @_;

delete $c->session->{'client'};

return 1;
}#---------------
1;