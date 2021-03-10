package MyBlog::Voting;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use Session;

#---------------------------------
sub likeartcl {
#---------------------------------
my $self = shift;

my $title_alias = $self->param('title_alias');
my $article_id  = $self->param('article_id');
my $user_id     = $self->param('user_id');
my $count = $self->menu->find( $title_alias, 
                               ['liked'], 
                               {'id' => $article_id} )
                               ->list + 1;

$self->menu->save( $title_alias, {'liked' => $count}, {'id' => $article_id} );
Session->voting( $self, 
                 'user'.$user_id.'_'.$title_alias.'_'.$article_id, 
                 $title_alias.'_'.$article_id 
               );

$self->render(
count => $count
);
}#---------------

#---------------------------------
sub unlikeartcl {
#---------------------------------
my $self = shift;

my $title_alias = $self->param('title_alias');
my $article_id  = $self->param('article_id');
my $user_id     = $self->param('user_id');
my $count = $self->menu->find( $title_alias, 
                               ['unliked'], 
                               {'id' => $article_id} )
                               ->list + 1;

$self->menu->save( $title_alias, {'unliked' => $count}, {'id' => $article_id} );
# Store session for a specific comment
Session->voting( $self, 
                 'user'.$user_id.'_'.$title_alias.'_'.$article_id, 
                 $title_alias.'_'.$article_id );

$self->render(
count => $count
);
}#---------------

#---------------------------------
sub likecomment {
#---------------------------------
my $self = shift;
my $table_comment = $self->top_config->{'table'}->{'comments'};
my $id = $self->param('comment_id');
my $user_id = $self->param('user_id');
my $count = $self->menu->find( $table_comment, ['liked'], {'id' => $id} )->list + 1;

$self->menu->save( $table_comment, 
                   {'liked' => $count}, 
                   {'id' => $id} 
                 );
Session->comment( $self, 'user'.$user_id.'_'.$id, $id );

$self->render(
count => $count
);
}#---------------

#---------------------------------
sub unlikecomment {
#---------------------------------
my $self = shift;
my $table_comment = $self->top_config->{'table'}->{'comments'};
my $id = $self->param('comment_id');
my $user_id = $self->param('user_id');
my $count = $self->menu->find( $table_comment, ['unliked'], {'id' => $id} )->list + 1;

$self->menu->save( $table_comment, 
                   {'unliked' => $count}, 
                   {'id' => $id} 
                 );
Session->comment( $self, 'user'.$user_id.'_'.$id, $id );

$self->render(
count => $count
);
}#---------------

1;