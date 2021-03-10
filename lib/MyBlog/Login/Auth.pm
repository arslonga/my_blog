package MyBlog::Login::Auth;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode);
use ParseMsg;
use MyBlog::Mail;

#---------------------------
sub registration_sess {
#---------------------------
my $self = shift;
my $language = $self->language;
my $msg_type = 'registration';
my $msg_type2 = 'newsletter_add';
my $table = $self->top_config->{'table'}->{'users'};
my $access_table = $self->top_config->{'table'}->{'access'};
my $redirect_to  = $self->param('redirect_to');
my $pattern_of_incorrect_login = $self->top_config->{'incorr_login_pattern'};
my $tempdir         = $self->top_config->{'captcha_temp'};
my $tempdir_registr = $self->top_config->{'registr_temp'};
my $url_tempdir = $tempdir; 
$url_tempdir =~ s/^public//;

my( %err_hash, $message, $body, $password, $pass_str, $session_code, $login, 
    $email, $err, $newsletter, $v );
$session_code = $self->param('session_code');
$pass_str     = $self->param('verifytext');
my @pass_chars_password = ("A".."Z", "a".."z", 0..9);

#***********************************
if($self->param('register')){
#***********************************
my $admin_check = $self->sess_check->admin($self);

    my $v = $self-> _validation( $self->top_config->{'adm'}->{'registration_required_fields'} );
    goto ENR if $v->has_error;
        
    ($login, $err) = $self->regexp->clean_login( trim($self->param('login')) );
    if( $err ){
     $err_hash{'err_login'} = $self->lang_config->{alert}->{$language}->{ $err->{login_err} };
     goto ENR;
    }
    ($email, $err) = $self->regexp->clean_email( trim($self->param('email')) );
    if( $err ){
     $err_hash{'err_email'} = $self->lang_config->{alert}->{$language}->{ $err->{email_err} };
     goto ENR;
    }
    ($password, $err) = $self->regexp->clean_passw( trim($self->param('passw')) );
    if( $err ){
     $err_hash{'err_passw'} = $self->lang_config->{alert}->{$language}->{ $err->{passw_err} };
     goto ENR;
    }
    
    #***************************
    if( $login && $email && $password ){
    #***************************
        #if( ( !$self->session('admin') || 
        #      $self->session('admin') ne $self->menu->find( $self->top_config->{table}->{access}, ['admin'] )->list)[0] ){
        if( !$admin_check ){
            foreach my $patrn( @$pattern_of_incorrect_login ){
                if($login =~ /$patrn/i){
                    $message = 'letter combination <b style="color:maroon">'.$patrn.'</b> is inadmissible!';
                    last;
                    goto ENR;
                }
            }
        }
    $newsletter = $self->param('newsletter');
    $newsletter = 'no' if(!$newsletter);

    my @where = ( {login => $login}, {email => $email} );
    my($exist_login_email_check) = $self->menu->find( $table, ['id'], \@where )->list;

    if($exist_login_email_check){
        $message = $self->lang_config->{'alert'}->{$language}->{'existing_login_or_passw'};
    }
    goto ENR if $message;
    $message = $self->captcha->check_anti_robot($self, $pass_str, $session_code);
    goto ENR if $message;
    my($from, $subject, $body) = $self->captcha->create_post_for_verif($self, $login, $session_code);
    
    $self->captcha->anti_new_session_reg( $self, 
        $session_code, 
        'Email:'.$email.'|Nickname:'.$login.'|Password:'.$password.'|Newsletter:'.$newsletter
    );
    MyBlog::Mail->as_html( $self->top_config->{noreply_mail}, $email, '', 'Registration', $body );
    $message = '<h4 align=center style = "color:blue">'.
    $self->lang_config->{msg_registr}->{$self->language}->{five}.
    '<b style="color:black">['.$email.']</b>.</h4>';
    }#*************
    
}#*************

#***********************************
if( $self->param('regid') ){
#***********************************
    my(%data_hash, $password);

    my $registr_data = $self->captcha->check_register_data($self);
    if($registr_data eq 'session_timeout'){
        $message = '<h4 align=center style="color:red">'.
        $self->lang_config->{alert}->{$self->language}->{session_timeout}.
        '</h4>';
        goto ENR;
    }
    foreach my $pair( split(/\|/, $registr_data) ){
        $data_hash{(split(/\:/, $pair))[0]} = (split(/\:/, $pair))[1];
    }
    $login = $data_hash{Nickname};
    $email = $data_hash{Email};
    $password = $data_hash{Password};
    my($exist_login_email_check) = $self->menu->find( $table, 
                                                      ['id'], 
                                                      [
                                                       {login => $login}, 
                                                       {email => $email}
                                                      ] 
                                                    )->list;
    goto REDRC if $exist_login_email_check;
    
    $newsletter = $data_hash{Newsletter};

    $body = ParseMsg->msg_registr( $self, 
                                   $self->top_config->{'msg_type'}->{$msg_type}, 
                                   $login, 
                                   $password 
                                 );
    $self->menu->create( $table, 
                         {
                          'curr_date' => $self->db_table->now($self),
                          'login' => $login,
                          'pass'  => $password,
                          'email' => $email,
                          'comment_quant' => 0,
                          'view_status' => 'yes',
                          'newsletter' => $newsletter,
                          'edit_priority' => ""
                         }
                       );
    #******************************                        
    if($newsletter eq 'yes'){ 
    #******************************
        my $id = $self->menu->find($table, ['id'], {'login' => $login})->list;
        my $cancel_link = $self->protocol.
        '://'.$self->req->url->to_abs->host.
        '/user.admin?newsletter=no&id='.$id;
        my $body_newsletter = 
        ParseMsg->msg_newsletter_add( $self, $self->top_config->{'msg_type'}->{$msg_type2} );
        $body.="\n".$body_newsletter."\n".$cancel_link;
    }#************
   
REDRC:
$self->redirect_to( $self->url_for('/authentication')
->query(
redirect_to => $self->param('redirect_to'),
msg => $self->param('msg')
)
);
}#*************

ENR:
($pass_str, $session_code) = $self->captcha->anti_new_session($self);
my $fileimag = $self->captcha->captcha( $self, $pass_str, $session_code );
my $menu = RewrMenu->active_rewrite($self);

E0:
$self->render(
language => $language,
url_tempdir => $url_tempdir,
description => '',
keywords => '',
menu => $menu,
session_code => $session_code,
err_login => $err_hash{'err_login'},
err_email => $err_hash{'err_email'},
err_passw => $err_hash{'err_passw'},
fileimag => $fileimag,
redirect_to => $redirect_to,
message => $message,
err_hash => $v,
title => $self->lang_config->{'labels'}->{$language}->{'registration'}
);
}#-------------

#---------------------------
sub authentication {
#---------------------------
my $self = shift;
my $language = $self->language;
my $template = $self->template;
my $msg_type = 'authentication';
my $table_users = $self->top_config->{'table'}->{'users'};
my $table_archive_menu = $self->top_config->{'table'}->{'archive_menu'};
my $redirect_to = $self->param('redirect_to');
my($message, $message_add, $email, $v);

my $authorize_required_fields = $self->top_config->{'authorize_required_fields'};

my $login    = $self->param('login');
my $password = $self->param('pass');

if($self->param('registration')){
    $self->redirect_to( $self->url_for('/registration')->
                        query(
                              redirect_to => $self->param('redirect_to')
                             )
                      );
}

########## Authorization request processing unit ###############################
if( $self->param('authorize') ){
    my $v = $self-> _validation( $authorize_required_fields );
    goto EN0 if $v->has_error;
    
    if( $login && $password ){
        my($login_exist, $pass_exist, $ban) = 
        $self->menu->find( $table_users, 
                           ['login', 'pass', 'banned'], 
                           {'login' => "$login", 'pass' => "$password"} 
                         )->list;

    if( !($login_exist && $pass_exist) ){
        $message = $self->lang_config->{'alert'}->{$language}->{'invalid_login_or_passw'};
    }
    if( $ban ){
        $message_add = $self->lang_config->{'alert'}->{$language}->{'you_banned'}; 
    }

    if( !($message) && !($message_add) ){  
        my $data = $self->menu->find( $table_users, 
                                      ['id', 'email'], 
                                      {'login' => "$login", 'pass' => "$password"} 
                                    )->hashes;
        my $id    = $data->[0]->{'id'};
        $email = $data->[0]->{'email'};
        
        Session->user($self, $id, $login, $email, $password);
    $self->redirect_to( $self->param('redirect_to') );                
    }
    }
}
################################################################################

EN0:
my $menu = RewrMenu->active_rewrite($self);
my $archive_menu = $self->menu->find( $table_archive_menu, 
                                      ['menu'], 
                                      {'url' => 'common'} 
                                    )->list;

$self->render(
template => lc($self->template).'/authentication',
language => $language,
description => '',
keywords => '',
menu => $menu,
archive_menu => $archive_menu,
redirect_to => $redirect_to,
message_add  => $message_add,
message => $message,
err_hash => $v,
title => $self->lang_config->{'labels'}->{$language}->{'authorization'}
);
}#-------------
1;