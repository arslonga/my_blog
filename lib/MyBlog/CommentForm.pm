package MyBlog::CommentForm;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use MyBlog::RssArticles;
use CommentClean;
use Session;

#---------------------------
sub comment_form {
#---------------------------
my($self, $c, $menu_level, $title_alias) = @_;
#my $language = $c->language;
my($message, $same_respons, $response_data);
my @comment_required_fields = $c->top_config->{'comment_required_fields'};
my $client_id;
eval{ $client_id = $c->session('client')->[0]; };
my $client_check = $c->sess_check->client( $c, $client_id );

eval{
if( $c->session('client')->[1] && $c->session('client')->[3] ){
    @comment_required_fields = 
    $c->top_config->{'comment_required_fields_authorized'};
}
};

my $page_id = $c->param('page_id');
my $login   = trim($c->param('log_in'));
$login      = $c->session('client')->[1] if( !$login && $client_check );
my $password = trim($c->param('passw'));
$password    = $c->session('client')->[3] if( !$password && $client_check );

if($c->param('registration')){
    $c->redirect_to( $c->url_for('/registration')->query(
                             redirect_to => $c->param('redirect_to')
                            )
                   );
}

#*********************************************           
if($c->param('send_respons')){
#*********************************************
    my $v = $c-> _validation( @comment_required_fields );
    my $comment = CommentClean->clean_comment($c, CommentClean->sbstr($c));
    return if( $v->has_error || !$comment );

    if( $login && $password ){
        my($login_exist, $pass_exist) = 
        $c->menu->find( $c->top_config->{'table'}->{'users'}, 
                        ['login', 'pass'], 
                        {'login' => "$login", 'pass' => "$password"}
                      )->list;
    
    if( !($login_exist && $pass_exist) ){
        $message = $c->lang_config->{'alert'}->
        {$c->language}->
        {'invalid_login_or_passw'};
    }

    $same_respons = $c->menu->find( $c->top_config->{'table'}->{'comments'}, 
                                    ['comment'], 
                                    {'comment' => trim($c->param('response'))}
                                  )->list;
    if($same_respons){
        $message = $c->lang_config->{'same_response_exist'}->{$c->language};
    }
    
    #**********************************
    if(!$message){ 
    #**********************************
        if( !$client_check ){
            my $data = $c->menu->find( $c->top_config->{'table'}->{'users'}, 
                                       ['id', 'email'], 
                                       {'login' => "$login", 'pass' => "$password"} 
                                     )->hashes;
            Session->user( $c, $data->[0]->{'id'}, $login, $data->[0]->{'email'}, $password);
        }
    
my $last_insert_id = $c->menu->create( $c->top_config->{'table'}->{'comments'}, 
                                   {
                                    curr_date => $c->db_table->now($c),
                                    parent_id => 0,
                                    level => 0,
                                    menu_level => $menu_level,
                                    nickname => $login,
                                    name => "",
                                    table_name => $title_alias,
                                    page_id => $page_id,
                                    url => $c->req->url,
                                    comment => $comment,
                                    press_indicat => 'yes'
                                   } );

MyBlog::RssArticles->rss_comments( $c );
Session->added_comment($c, $last_insert_id);
    $c->redirect_to($c->req->url.'#'.$c->top_config->{'comment_prefix'}.$last_insert_id);      
                   
    }#************
    }
}#***************

return $message;
}#-------------
1;