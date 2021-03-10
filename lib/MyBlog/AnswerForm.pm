package MyBlog::AnswerForm;
use Mojo::Base 'Mojolicious::Controller';
use ParseMsg;
use MyBlog::Mail;
use CommentClean;
use MyBlog::RssArticles;
use Mojo::Util qw(trim);

#---------------------------
sub answer_form {
#---------------------------
my($self, $c, $menu_level, $title_alias) = @_;
my $msg_type = 'msg_respons';
my $table_users = $c->top_config->{'table'}->{'users'};
my $table_comments = $c->top_config->{'table'}->{'comments'};
my $body_mail;

my $page_id   = $c->param('page_id');
my $login     = $c->session('client')->[1];
my $password  = $c->session('client')->[3];
my $parent_id = $c->param('parent_id');
my $level     = $c->param('level');

#****************************           
if($c->param('send_answ')){
#****************************
    my $v = $c-> _validation($c->top_config->{'answer_required_fields'});
    my $answer = CommentClean->clean_comment($c, CommentClean->sbstr_answ($c));
    return if( $v->has_error || !$answer || !$c->param('page_id') );
    
my $last_insert_id = $c->menu->create( $c->top_config->{'table'}->{'comments'}, 
                                      {
                                       curr_date   => $c->db_table->now($c),
                                       parent_id   => $parent_id,
                                       level       => $level,
                                       menu_level  => $menu_level,
                                       nickname    => $login,
                                       name        => "",
                                       table_name  => $title_alias,
                                       page_id     => $c->param('page_id'),
                                       url         => $c->req->url,
                                       comment     => $answer,
                                       press_indicat => 'yes'
                                     });

    MyBlog::RssArticles->rss_comments($c);
    my $parent_user = $c->menu->find($table_comments, ['nickname'], {'id' => $parent_id})->list;
    my $parent_user_email = $c->menu->find($table_users, ['email'], {'login' => $parent_user})->list;

    $body_mail = ParseMsg->msg_about_response( $c, $c->top_config->{'msg_type'}->{$msg_type}, 
                                               $parent_user, $login, $parent_id, $last_insert_id );

    MyBlog::Mail->as_html($c->top_config->{'noreply_mail'}, $parent_user_email, 
                          $c->menu->find( $c->top_config->{table}->{access}, ['email'] )->list, 
                          'response',
                          $body_mail);
        
    Session->added_comment( $c, $last_insert_id ); 
    $c->redirect_to( $c->req->url.'#'.$c->top_config->{'comment_prefix'}.$last_insert_id );

}#***********

return;
}#-------------

#---------------------------
sub edit_response {
#---------------------------
my($self, $c) = @_;
my $table_comments = $c->top_config->{'table'}->{'comments'};
my($message, $response_data);

my $edit_respons_required_fields = $c->top_config->{'edit_respons_fields'};
           
if($c->param('edit_respons')){
    my $v = $c-> _validation( $c->top_config->{'edit_respons_fields'} );
    my $answer = trim( CommentClean->clean_edited( $c, CommentClean->sbstr_edit($c) ) );
    return if( $v->has_error || !$answer || !$c->param('parent_id') );
 
    $c->menu->save($table_comments, {'comment' => $answer}, {'id' => $c->param('parent_id')});

    MyBlog::RssArticles->rss_comments($c);
    $c->redirect_to($c->param('redirect_to'));                 
}
return;
}#-------------
1;