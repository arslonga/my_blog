package MyBlog::Users;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use MyBlog::RssArticles;
use EveryParam;
use Session;

#---------------------------
sub manage {
#---------------------------
my $self = shift;
my $language = $self->language;
my $template = $self->template;
my $table_users = $self->top_config->{'table'}->{'users'};
my $table_comments = $self->top_config->{'table'}->{'comments'};
my $id = $self->param('id');

#**********************************
if($self->param('ban')){
#**********************************
my @edit_prior = split(/\|/, $self->menu->find( $table_users, 
                                                ['edit_priority'], 
                                                {'id' => $id} )->list);
my $nickname = $self->menu->find( $table_users, ['login'], {'id' => $id} )->list;
#goto RNDR0;

#foreach my $item( @edit_prior ){
#    foreach( @{$self->menu->save( $item, {'author_id' => '0'}, {'author_id' => $id} )->flat} ){
#    }
#}
eval{
    $self->menu->save( $table_comments, 
                       {'press_indicat' => 'no'},  
                       {'nickname' => $nickname} );
    #$self->menu->save( $table_users, {'newsletter' => 'no', 'view_status' => 'no'}, {'id' => $id} );
    $self->menu->save( $table_users, {'banned' => 'yes'}, {'id' => $id} );
    };
    #$self->menu->delete( $table_users, {'id' => $id});
    # Закриваємо сесію для користувача
    #Session->client_expire($self);
}#***********

#**********************************
if($self->param('delete')){
#**********************************
my @edit_prior = split(/\|/, $self->menu->find( $table_users, 
                                                ['edit_priority'], 
                                                {'id' => $id} )->list
                                              );
foreach my $item( @edit_prior ){
    foreach( @{$self->menu->save( $item, {'author_id' => '0'}, {'author_id' => $id} )->flat} ){
    }
}
eval{
    #$self->menu->delete( $table_comments, {'nickname' => $self->menu->find( $table_users, ['login'], {'id' => $id} )->list} );
    };
    #$self->menu->delete( $table_users, {'id' => $id});
    # Закриваємо сесію для користувача
    Session->client_expire($self);
}#***********

RNDR0:
$self->render(
language => $language,
content => [$self->menu->find( $table_users, ['*'], undef, 'id' )->hashes],
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{users}->{$language},
head => $self->lang_config->{users}->{$language},
);
}#-------------

#---------------------------
sub comments_list {
#---------------------------
use CommentsRef;
my $self = shift;
my $language = $self->language;
my $table_users = $self->top_config->{'table'}->{'users'};
my $table_comments = $self->top_config->{'table'}->{'comments'};
my $id = $self->param('id');
my $id_in_limit_rss;
my $ban = $self->ban_status( $table_users, $id );

my $id_comment = $self->param('id_comment'); # || $db->select($table_comments, ['id'], {'nickname' => $self->param('nickname')})->list;
#goto M0;

#********************************
if($self->param('delete')){
#********************************
    $self->menu->save( $table_comments, 
                       {
                        'comment' => $self->lang_config->{'comment_deleted'}->{$language},
                        'press_indicat' => 'del'
                       }, 
                        {'id' => $id_comment} 
                     );
    #$self->menu->delete( $table_comments, {'id' => $id_comment} );
    $id_in_limit_rss = $self->db_table->id_comment_in_limit_rss($self, $id_comment);
    if($id_in_limit_rss){
        MyBlog::RssArticles->rss_comments($self);
    }
$self->redirect_to( "/comments_list?id=$id" );    
}#********

#M0:
my $content = $self->menu->find( $table_users, ['login'], {'id' => $id} )->hash;
my $page_head = CommentsRef->comments_ref_user( $self, $content->{'login'} );

$self->render(
language => $language,
id => $id,
ban => $ban,
page_head => [@$page_head],
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $content->{'login'},
head => $self->lang_config->{users}->{$language},
);
}#-------------

#---------------------------
sub comment {
#---------------------------
use CommentsRef;
my $self = shift;
my $language = $self->language;
my $table_users = $self->top_config->{'table'}->{'users'};
my $table_comments = $self->top_config->{'table'}->{'comments'};
my $user_id = $self->param('user_id');
my $ban = $self->ban_status( $table_users, $user_id );
#my $action = 'encode_'.$self->db_driver;

my $id_comment = $self->param('id') || 
$self->menu->find( $table_comments, 
                   ['id'], 
                   {'nickname' => $self->param('nickname')} 
                   )->list;
my $press_indicat = 'yes';
$press_indicat = $self->param('press_indicat') if($self->param('press_indicat'));

#********************************
if($self->param('comment')){
#********************************
if( $ban eq 'ban' ){ 
  goto RNDRCOMNT;
}
my $comment = $self->param('comment');

$comment =~ s/<p>\&nbsp\;<\/p>//g;
$comment =~ s/<\s*p\s*>//g; $comment =~ s/<\s*\/p\s*>//g;

$self->menu->save( $table_comments, 
                   {'comment' => $comment, 'press_indicat' => $press_indicat}, 
                   {'id' => $id_comment}
                 );
$self->redirect_to( $self->url_for("/user.comment")->
                    query(
                          id      => $id_comment,
                          user_id => $user_id
                         )
                  );
MyBlog::RssArticles->rss_comments( $self );
}#********

RNDRCOMNT:
my $hash_ref = $self->menu->find( $table_comments, ['*'], {'id' => $id_comment} 
                                )->hash;
my $head = $self->menu->find( $hash_ref->{'table_name'}, 
                              ['head'], 
                              {'id' => $hash_ref->{'page_id'}} 
                            )->list;

$self->render(
language => $language,
id => $id_comment,
user_id => $user_id,
ban => $ban,
page_head => $head,
content => $hash_ref,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $hash_ref->{'nickname'},
head => $self->lang_config->{users}->{$language},
);
}#-------------

#---------------------------
sub properties {
#---------------------------
my $self = shift;
my $language = $self->language;
my $table_users = $self->top_config->{'table'}->{'users'};
my $table_comments = $self->top_config->{'table'}->{'comments'};
my $id = $self->param('id');
my $ban = $self->ban_status( $table_users, $id );

#**********************************
if( $self->param('edit') && !$ban ){
#**********************************
    $self->menu->save($table_users, {
                                'newsletter' => $self->param('newsletter'),
                                'view_status' => $self->param('view_status')
                              }, {'id' => $id});
}#***********

my $content = $self->menu->find( $table_users, ['*'], {'id' => $id} )->hash;
$content->{'comments_count'} = $self->menu->find( $table_comments, 
                                                  ['count(*)'], 
                                                  {'nickname' => $content->{'login'}} 
                                                )->list;

$self->render(
language => $language,
content => $content,
ban => $ban,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $content->{'login'},
head => $self->lang_config->{users}->{$language},
);
}#-------------

#---------------------------
sub priority_edit {
#---------------------------
my $self = shift;
my $language = $self->language;
my $table_users = $self->top_config->{'table'}->{'users'};
my(%titlealias_title, @chapters_valid);
my @title_alias = @{TitleAliasList->title_alias_list_for_priorEdit( $self )};

my $id = $self->param('id');
my $ban = $self->ban_status( $table_users, $id );

my $login = $self->menu->find($table_users, ['login'], {'id' => $id})->list;

#********************************
if($self->param('set')){
#********************************    
    foreach my $title_alias( EveryParam->get_array_users_opt($self, 'chapter') ){
        my $list_enable = $self->menu->find( $self->menu->find( $title_alias, ['level'] )->list, 
                                             ['list_enable'], 
                                             {'title_alias' => $title_alias} 
                                           )->list;
        push @chapters_valid, $title_alias if($list_enable eq 'yes');
    }
    $self->menu->save( $table_users, 
                       {'edit_priority' => join('|', @chapters_valid)}, 
                       {'id' => $id} );
$self->redirect_to( '/set.priority_edit?id='.$id );
}#***********

foreach my $title_alias(@title_alias){
    my $title = $self->menu->find( $self->menu->find($title_alias, ['level'] )->list, 
                                   ['title'], 
                                   {'title_alias' => $title_alias} )->list;
    $titlealias_title{$title_alias} = $title;
}
my @edit_priority = split( /\|/, $self->menu->find( $table_users, 
                                                   ['edit_priority'], 
                                                   {'id' => $id} 
                                                  )->list );

$self->render(
language => $language,
login => $login,
ban => $ban,
id => $id,
content => [@title_alias],
edit_priority => [@edit_priority],
chapter => {%titlealias_title},
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $login
);
}#-------------

#---------------------------
sub forgot_passw {
#---------------------------
use MyBlog::Mail;
use ParseMsg;
use Mojo::URL;

my $self = shift;
my $language = $self->language;
my $template = $self->template;
my $templ = lc($template).'/forgot_passw';
my $actual_title = $self->lang_config->{'remind_password_form'}->{$language};
my $table_users = $self->top_config->{'table'}->{'users'};
my $access_table = $self->top_config->{'table'}->{'access'};
my $msg_type = 'forgot_passw';
my(%err_hash, %data_hash, $message, $reset_data);
my $redirect_to = $self->param('redirect_to');
my $session_code = $self->param('session');

#**********************************
if( $self->param('change_passw') ){
#**********************************
$templ = lc($template).'/reset_passw';
my $v = $self-> _validation( $self->top_config->{'reset_passw_required_fields'} );
goto EN if $v->has_error;

my($password, $err) = $self->regexp->clean_passw( trim($self->param('passw')) );
    if( $err ){
     $message = $err_hash{'err_passw'} = $self->lang_config->{alert}->{$language}->{ $err->{passw_err} };
     goto EN;
    }

    $reset_data = $self->captcha->check_reset_data($self);
    foreach my $pair( split(/\|/, $reset_data) ){
        $data_hash{(split(/\:/, $pair))[0]} = (split(/\:/, $pair))[1];
    }
    $self->menu->save( $table_users, {pass => $password}, {id => $data_hash{Id}} );
    $self->captcha->del_old_session($self, 'reset_temp', "0");
$self->redirect_to( '/authentication?redirect_to=/' );
}#***********

#**********************************
if( $self->param('option') eq 'reset' ){
#**********************************
my %data_hash;
$templ = lc($template).'/reset_passw';
    $reset_data = $self->captcha->check_reset_data($self);
    if( $reset_data eq 'session_timeout' ){
        $message = '<h4 align=center style="color:red">'
        .$self->lang_config->{alert}->{$self->language}->{session_timeout}.'</h4>';
        goto EN;
    }
goto EN;
}#***********

#**********************************
if($self->param('send')){
#**********************************
    my $v = $self-> _validation( $self->top_config->{'forgot_passw_required_fields'} );
    goto EN if $v->has_error;
    
    my $email = $self->regexp->name_clean( trim($self->param('email')) );
    
    my($id, $login, $password) = $self->menu->find( $table_users, 
                                                    ['id', 'login', 'pass'], 
                                                    {'email' => $email} )->list;
    $login = encode('utf8', $login);

    if(!$login){
        $message = '['.$email.'] - '.$self->lang_config->{'not_exist_email'}->{$language};
        goto EN;
    }
    # Session code for reseting password
    $session_code = $self->captcha->enctypt_session_code;
    $self->captcha->anti_new_session_reset_passw( $self, 
                                                  $session_code, 
                                                  'Nickname:'.$login.'|Id:'.$id 
                                                );

    my $body = ParseMsg->msg_forgot_passw( $self, 
                                           $self->top_config->{'msg_type'}->{$msg_type}, 
                                           $login, $session_code 
                                         );

    MyBlog::Mail->as_html( $self->top_config->{'noreply_mail'}, 
                           $email, 
                           $self->menu->find( $access_table, ['email'] )->list,
                           $self ->lang_config->{'remind_passw'}->{$language}.' '.
                           $self->req->url->to_abs->host, #subject
                           $body);
    #$self->redirect_to($self->req->url);
    $actual_title = $self->lang_config->{'go_to_reset_passw'}->{$language};
}#***********

EN:
my $menu = RewrMenu->active_rewrite($self);

$self->render(
template => $templ,
language => $language,
description => '',
keywords => '',
menu => $menu,
redirect_to => $redirect_to,
message => $message,
reset_data => $reset_data,
session_code => $session_code,
title => 'Remind password',
actual_title => $actual_title
);
}#-------------

#---------------------------
sub profile {
#---------------------------
use MyBlog::Mail;
use ParseMsg;
my $self = shift;
my $language = $self->language;
my $msg_type = 'change_profile';
my $msg_type2 = 'newsletter_add';
my $table_users = $self->top_config->{'table'}->{'users'};
my $table_comments = $self->top_config->{'table'}->{'comments'};
my $access_table = $self->top_config->{'table'}->{'access'};
my(%err_hash, $v, $message, $content, $body);
my $client_id;
eval{ $client_id = $self->session('client')->[0]; };
my $client_check = $self->sess_check->client( $self, $client_id );
my $newsletter = 'no';

my $id = $self->param('id') || $self->session('client')->[0];
my $redirect_to = $self->param('redirect_to');

#***************************
if($self->param('exit')){
#***************************
if( $client_check ){
    Session->client_expire( $self, $self->param('id') );
}
return $self->redirect_to($self->param('redirect_to'));
}#*********

#*******************************************************    
if( $self->param('edit') ){
#*******************************************************
    $v = $self-> _validation( $self->top_config->{'profile_required_fields'} );
    goto ENA if $v->has_error;
    
    my($password, $err) = $self->regexp->clean_passw( trim($self->param('pass')) );
    if( $err ){
     $message = $err_hash{'err_passw'} = 
     $self->lang_config->{alert}->{$language}->{ $err->{passw_err} };
     goto ENA;
    }
    
    $newsletter = $self->param('newsletter') if($self->param('newsletter'));
    $self->menu->save( $table_users, 
                       {'pass' => $password, 'newsletter' => $newsletter}, 
                       {'id' => $id} 
                     );
    my($login, $email) = $self->menu->find( $table_users, 
                                            ['login', 'email'], 
                                            {'id' => $id} 
                                          )->list;
    
    Session->client_expire( $self, $self->param('id') );
    
    $login = encode('utf8', $login);
    
    $body = ParseMsg->msg_change_profile( $self, 
                                          $self->top_config->{'msg_type'}->{$msg_type}, 
                                          $login, 
                                          $password );
    #****************************                          
    if($newsletter eq 'yes'){
    #****************************
        my $cancel_link = $self->protocol.'://'.
        $self->req->url->to_abs->host.
        '/user.admin?newsletter=no&id='.$id;
        my $body_newsletter = 
        ParseMsg->msg_newsletter_add( $self, $self->top_config->{'msg_type'}->{$msg_type2} );
        $body.="\n".$body_newsletter."\n".$cancel_link;
    }#***********
    
    # Email notification of a user's profile change 
    MyBlog::Mail->just_text( $self->top_config->{'noreply_mail'}, 
                             $email, 
                             $self->menu->find( $access_table, ['email'] )->list, 
                             $self ->lang_config->{'change_profile'}->{$language}.
                             ' '.$self->req->url->to_abs->host, #subject
                             $password, $body );
                            
    return $self->redirect_to($self->param('redirect_to'));
}#************

ENA:
$content = $self->menu->find( $table_users, ['*'], {'id' => $id} )->hash;
eval{
$content->{'pass'} = "" if($v->has_error);
};

$self->render(
language => $language,
message => $message,
redirect_to => $redirect_to,
content => $content,
body => $body,
title => $self->session('client')->[1],
head => $self->lang_config->{users}->{$language},
);
}#-------------

#---------------------------
sub ban_status {
#---------------------------
my($self, $table_users, $user_id) = @_;
my $ban;
my($nickname, $banned) = $self->menu->find( $table_users, 
                                            ['login', 'banned'], 
                                            {'id' => $user_id} )->list;
if($banned){ return 'ban' }
}#-------------
1;