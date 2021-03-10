package MyBlog::Like;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use Session;

#---------------------------------
sub responce {
#---------------------------------
my $self = shift;
my $table_comment = $self->top_config->{'table'}->{'comments'};
my $count      = $self->param('count');
my $comment_id = $self->param('comment_id');
my $user_id    = $self->param('user_id');

$self->menu->save( $table_comment, 
                   {'liked' => $count}, 
                   {'id' => $comment_id} 
                 );
Session->comment( $self, 
                  'user'.$user_id.'_'.$comment_id, 
                  $comment_id 
                );

$self->render(
count => $count
);
}#---------------
1;