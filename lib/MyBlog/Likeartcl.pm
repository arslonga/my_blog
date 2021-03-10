package MyBlog::Likeartcl;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use Session;

#---------------------------------
sub respnse {
#---------------------------------
my $self = shift;
my $count = $self->param('count');

my $title_alias = $self->param('title_alias');
my $article_id  = $self->param('article_id');
my $user_id     = $self->param('user_id');

$self->menu->save( $title_alias, {'liked' => $count}, {'id' => $article_id} );
Session->voting( $self, 
                 'user'.$user_id.'_'.$title_alias.'_'.$article_id, 
                 $title_alias.'_'.$article_id 
               );

$self->render(
count => $count
);
}#---------------
1;