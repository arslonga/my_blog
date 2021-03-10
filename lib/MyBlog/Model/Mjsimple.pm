package MyBlog::Model::Mjsimple;
use Mojo::Base -base;
use Mjsimple::MenuClient;

has 'db';

#-------------------------
sub url_modif {
#-------------------------
my($self, $c) = @_;
my $url = $c->req->url;
$url =~ s/\/$// if($url =~ /\/$/ && $url ne '/');
#if( $c->param('page') || $c->param('last_id') ){
if( $c->param('page') ){
    $url =~ s/\?.*$//;
}
return $url;
}#----------

#----------------------------------
sub get_menu{
#----------------------------------
my($self, $c, $ref_hash_dir_subs) = @_;

return Mjsimple::MenuClient->menu($c, $ref_hash_dir_subs);
}#--------------

#----------------------------------
sub menu_rewrite{
#----------------------------------
my($self, $c, $menu) = @_;

foreach my $table(sort @{$c->top_config->{'levels'}}){
    my $result = $c->menu->find( $table, ['url', 'id', 'in_menu'] );
    while( my($pattern, $id, $in_menu) = $result->list ){
        my $pattern_mod = '<a href="'.$pattern.'">';
        $pattern_mod = '<a class="activ" href="'.$pattern.'">' if($in_menu eq 'no');
        
        if( $table eq 'level0' || $table eq 'level1' ){
            my $curr_menu = $menu;
                $curr_menu =~ /($pattern_mod)/;
            if($in_menu eq 'no'){
                $curr_menu =~ s/$pattern_mod//;
            }else{
                $curr_menu =~ s/$1/<a class\=\"activ\" href=\"$pattern\">/;
            }
            $c->menu->save( $table, {menu => $curr_menu}, {id => $id} );
        }else{
            $c->menu->save( $table, {menu => $menu}, {id => $id} );
        }
        
    }
}
return 1;
}#--------------

#-------------------------
sub pagination_attr {
#-------------------------
my( $self, $c, $key ) = @_;
my( %pagination_attr, $limit_str, $offset, $current_page, $attr_file );

if( !$key ){
    $attr_file = $c->top_config->{'pagination_attr_file'};
}else{
    $attr_file = $c->top_config->{$key};
}
my @pgn_attr = split(/\|/, $c->slurp($attr_file));
$pagination_attr{ (split(/\:/, $pgn_attr[0]))[0] } = (split(/\:/, $pgn_attr[0]))[1];
$pagination_attr{ (split(/\:/, $pgn_attr[1]))[0] } = (split(/\:/, $pgn_attr[1]))[1];
$pagination_attr{ (split(/\:/, $pgn_attr[2]))[0] } = (split(/\:/, $pgn_attr[2]))[1];
$pagination_attr{ (split(/\:/, $pgn_attr[3]))[0] } = (split(/\:/, $pgn_attr[3]))[1];

$limit_str = $pagination_attr{'annot_numb'};

if($c->param('page')){
    $current_page = $c->param('page') || 1;
    $offset = ($current_page - 1) * $limit_str;
}else{
    $offset = 0;
    $current_page = 1;
}
return(\%pagination_attr, $current_page, $limit_str, $offset);
}#----------

#-------------------------
sub comments {
#-------------------------
my($self, $c, $table, $title_alias, $id) = @_;
my $table_comments = $c->top_config->{'table'}->{'comments'};
my($client_id, $message_of_comment);
eval{ $client_id = $c->session('client')->[0]; };
my $client_check = $c->sess_check->client( $c, $client_id );

$message_of_comment = MyBlog::CommentForm->comment_form( $c, $table, $title_alias );
    if( $client_check ){
        MyBlog::AnswerForm->answer_form( $c, $table, $title_alias );
        MyBlog::AnswerForm->edit_response( $c );
    }
my $comments_tree = MyBlog::CommentsTree->comments_tree( $c, $id );
return ( $message_of_comment, $comments_tree );
}#----------
1;