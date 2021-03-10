package MyBlog::Model::CommentCount;
use Mojo::Base -base;

#----------------------------------
sub comment_count {
#----------------------------------
  my($c, $self, $content, $title_alias) = @_;
  my $table_comments = $self->top_config->{'table'}->{'comments'};
  return $self->menu->find( $table_comments, 
                            ['count(page_id)'], 
                            {
                             'page_id' => $content->[0]->{'id'}, 
                             'table_name' => $title_alias,
                             'press_indicat' => 'yes'
                            } )->list;  
}#------------

1;