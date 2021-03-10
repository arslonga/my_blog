package MyBlog::Author;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim);
use Moj::Util;
use Session;

#---------------------------------
sub access {
#---------------------------------
my $self = shift;

my(%err_hash, $message, $email_err, $access_configured_status, $access_check_config,
  $pass, $login, $email);
my $table = $self->top_config->{'adm'}->{'table'}->{'access'}->{'name'};
my $columns = $self->top_config->{'adm'}->{'table'}->{'access'}->{'columns'};
my $mess_prefix = $self->lang_config->{'labels'}->{$self->language}->{'wrong_configure_db'};
eval{
    $access_configured_status = 
    $self->slurp( 'conf/'.
                  $self->language.'/'.
                  $self->top_config->{'access_configured_status_file'}
                );
};

my($db, $err) = DB->connect_db($self);

if($err){
    $message = $mess_prefix.' '."<b style=\"color:red\">$err</b>";
    goto RENDRACCESS;
}
# Checking existence of all tables
#eval{
    foreach( @{$self->top_config->{'need_tables_adm'}} ){
        my($table_live) = $self->db_table->like_table($self, $_);
        if(!$table_live){
            $self->db_table->create_struct($self, $_, $_);
        };
    }
#};
#**********************
if( $self->param('access') ){
#**********************
    # Checking filling of the form fields
    my $v = $self-> _validation($self->top_config->{'adm'}->{'access_required_fields'});
    goto RENDRACCESS if $v->has_error;
    
    ($login, $err) = $self->regexp->clean_login( trim($self->param('login')) );
    if( $err ){
        $err_hash{'err_login'} = 
        $self->lang_config->{alert}->{$self->language}->{ $err->{login_err} };
        goto RENDRACCESS;
    }
    ($pass, $err) = $self->regexp->clean_passw( trim($self->param('pass')) );
    if( $err ){
        $err_hash{'err_passw'} = 
        $self->lang_config->{alert}->{$self->language}->{ $err->{passw_err} };
        goto RENDRACCESS;
    }
    ($email, $err) = $self->regexp->clean_email( trim( $self->param('email') ) );
    if( $err ){
        $err_hash{'err_email'} = 
        $self->lang_config->{alert}->{$self->language}->{ $err->{email_err} };
        goto RENDRACCESS;
    }
    
    $self->spurt( $self->config('secrets')->[0], 
    'conf/'.$self->language.'/'.$self->top_config->{'db_configured_status_file'}
                );
    $self->spurt( $self->config('secrets')->[0], 
    'conf/'.$self->language.'/'.$self->top_config->{'access_configured_status_file'});
    $db->abstract = SQL::Abstract->new;
    
    my @data = $db->select($table, '*')->list;
    if( @data ){
        $db->update( $table, 
                     {
                      $columns->[0] => $login, 
                      $columns->[1] => $pass, 
                      $columns->[2] => $email
                     }
                   );
    }else{
        $db->insert( $table, [$login, $pass, $email] );
    }
$self->spurt( '', 'conf/'.$self->language.'/tmp' );
$self->redirect_to('admin');
}#*********

$self->redirect_to('dbaccess') unless $db;

$access_check_config = $self->sess_check->check_config( $self, 'access' );
$self->sess_check->check_config( $self, 'access_next', $access_check_config );

RENDRACCESS:
$self->render(
err_login => $err_hash{'err_login'},
err_passw => $err_hash{'err_passw'},
email_err => $err_hash{'err_email'},
message => $message,
title => $self->lang_config->{'labels'}->{$self->language}->{'access_admin_config'}
);
}#---------------

#---------------------------------
sub dbaccess {
#---------------------------------
my $self = shift;
my ($message, $host_name, $dbdriver_configured_status, $db_configured_status,
    $explain_ab_restart, $checking_reconf, $db_check_config);
my $added_param = '';
my $mess_prefix = $self->lang_config->{'labels'}->{$self->language}->{'wrong_configure_db'};

eval{
$db_configured_status = trim( $self->slurp('conf/'.$self->language.'/'.
$self->top_config->{'db_configured_status_file'}) );
};

#**********************************
if( $self->param('dbaccess') ){
#**********************************
    my $v = $self-> _validation($self->top_config->{'adm'}->{'dbaccess_required_fields'});
    goto RENDR if $v->has_error;
    
    $host_name   = trim($self->param('host'));
    my $username = trim($self->param('user'));
    my $pass     = trim($self->param('pass'));
    my $database = trim($self->param('dbname'));
    
#my $db_attr_string = 'host:'.$host_name.'|username:'.$username.'|password:'.$pass.'|database:'.$database;
#$self->spurt( $db_attr_string, 
#'conf/'.$self->language.'/'.$self->top_config->{'db_attr_file'} );

#=====================================
my $db_conf_content = $self->render_to_string(
template => 'conf/comirka',
host => $host_name,
username => $username,
password => $pass,
database => $database
);
$self->spurt( trim($db_conf_content), 'conf/'.$self->language.'/comirka.conf' );
#=====================================

$self->spurt( $self->config('secrets')->[0], 
'conf/'.$self->language.'/'.$self->top_config->{'db_configured_status_file'} );
$self->spurt( $self->config('secrets')->[0], 
'conf/'.$self->language.'/'.$self->top_config->{'dbdriver_configured_status_file'} );

my($db, $err) = DB->connect_db( $self );
if($err){
    $self->spurt( '', 'conf/'.$self->language.'/'.$self->top_config->{'db_configured_status_file'} );
    $message = $mess_prefix.' '."<b style=\"color:red\">$err</b>";
    $added_param = 'request_reconf|reconf_access';
    goto RENDR;
}
if( $self->param('request_reconf') eq 'reconf_access' ){
    $self->spurt( 'yes', 'conf/'.$self->language.'/tmp' );
    $checking_reconf = 1;
    goto RENDR;
}else{
    $self->spurt( 'yes', 'conf/'.$self->language.'/tmp' );
    return $self->redirect_to('/access');
}
    
#return $self->redirect_to('/access');
}#***********

$db_check_config = $self->sess_check->check_config( $self, 'dbaccess' );

if( $self->param('request') eq 'fatal_err' ){
    $db_check_config = 1;
}

if( !$db_check_config ){
    $self->redirect_to('/admin');
}else{
    if( $db_configured_status ){
        $explain_ab_restart = $self->lang_config->{'explain_ab_restart'}->{$self->language};
        $added_param = 'request_reconf|reconf_access';
    }else{
        $explain_ab_restart = '';
        $added_param = '';
    }
}

use Cwd;
chdir cwd();

foreach(@{$self->top_config->{'need_ditectories'}}){
    mkdir($_, 0755);
}

RENDR:
$self->render(
message => $message,
explain_ab_restart => $explain_ab_restart,
checking_reconf => $checking_reconf,
added_param => $added_param,
host_name => $host_name,
language => $self->language,
title => $self->lang_config->{'labels'}->{$self->language}->{'dbaccess_admin_config'}
);
}#---------------

#---------------------------------
sub dbdriver {
#---------------------------------
my $self = shift;
my($message);

if($self->param('dbdriver')){
    $self->spurt( $self->config('secrets')->[0], 
    'conf/'.$self->language.'/'.$self->top_config->{'dbdriver_configured_status_file'} );
    $self->spurt( $self->param('dbdriver'), 
    'conf/'.$self->language.'/'.$self->top_config->{'db_driver_file'} );
    goto RENDR;
}

my $dbdriver_check_config = $self->sess_check->check_config( $self, 'db_driver' );

if( !$dbdriver_check_config ){
    $self->redirect_to('/admin');
}

RENDR:
$self->render(
message => $message,
title => $self->lang_config->{'labels'}->{$self->language}->{'dbdriver_set'},
);
}#---------------

#---------------------------------
sub admin {
#---------------------------------
my $self = shift;
my($message, $db, $err, $db_err, $access_configured_status);
my $language = $self->language;
my $access_configured_status_file = 'conf/'.$language.'/'.$self->top_config->{'access_configured_status_file'};
#Таблиця 'user_passw' атрибутів достубу до консолі адміну
my $table_access = $self->top_config->{'adm'}->{'table'}->{'access'}->{'name'};

# Масив полів форми, що обов'язково мають бути заповнені
my $admin_required_fields = $self->top_config->{'adm'}->{'admin_required_fields'};
my $mess_prefix = $self->lang_config->{'labels'}->{$self->language}->{'wrong_configure_db'};

eval{
$access_configured_status = 
$self->slurp('conf/'.$self->language.'/'.$self->top_config->{'access_configured_status_file'});
};

if( $access_configured_status ne $self->config('secrets')->[0] ){
  $self->redirect_to('/access');
}

my $instance = 'create_table'.$self->db_driver;

use Cwd;
chdir cwd();
# Creating needed directories
foreach(@{$self->top_config->{'need_ditectories'}}){
    mkdir($_, 0755);
}

($db, $err) = DB->connect_db($self); #, [@{$self->top_config->{'need_tables_adm'}}]);

# Якщо є помилка, виводимо повідомлення про неправильне конфігурування БД для шаблону
if($err){
    $message = $mess_prefix.' '."<b style=\"color:red\">$err</b>";
    $db_err = 1;
    goto RENDRA;
}

# Масив таблиць рівнів для даного шаблону
foreach( @{$self->top_config->{'levels'}} ){#-------------
    # Перевіряємо наявність поточної таблиці рівня
    my($table_live) = $self->db_table->like_table($self, $_);
    # Створюємо таблицю рівня, якщо її немає
    if( !$table_live ){
            $self->db_table->create_table($self, $_, 'level');
    }
    ($table_live) = $self->db_table->like_table($self, 'main');
    if( !$table_live ){
            $self->db_table->create_table($self, 'main', 'main');
    }
}#---------------------------------------------------------------------

$self->spurt( 
$self->config('secrets')->[0], 
'conf/'.$language.'/'.$self->top_config->{'access_configured_status_file'}
);

#****************************************
if( $self->param('enter') ){
#****************************************
    # Перевіряємо, чи всі поля форми заповнені
    my $v = $self-> _validation($self->top_config->{'adm'}->{'admin_required_fields'});
    goto RENDRA if $v->has_error;

    my $access_row = $self->menu->find($table_access, '*')->hash;
    my $login   = $access_row->{admin};
    my $passwrd = $access_row->{password};
    
    #***************
    if( $login eq trim($self->param('login')) && $passwrd eq trim($self->param('pass')) ){
    #***************

    foreach(@{$self->top_config->{'need_tables_main'}}){
        my($table, $key) = split(/\-/, $_);
        my $id = $self->menu->find($table, ['id'])->list;

        if( !$id ){
            DB::Insert->insert($self, $table, $table);
        }
    }
    #my($menu, $sitemap) = $self->serve->get_menu( $self, $self->serve->select_struct($self, [reverse sort @{$self->top_config->{'levels'}}]) );
    my($menu, $sitemap) = 
    $self->routine_model->get_menu( 
        $self, $self->serve->select_struct($self, [reverse sort @{$self->top_config->{'levels'}}]) 
    );
    $self->routine_model->menu_rewrite( 
        $self, $menu, [reverse sort @{$self->top_config->{'levels'}}] 
    );

    # Встановлюємо куки для сесії адміністратора
    Session->admin($self, $login, $passwrd);

    $self->redirect_to('/manager');
    }else{ #***********
        $message = $self->lang_config->{'alert'}->{$self->language}->{'invalid_login_or_passw'};
    } #****************

}#*************

RENDRA:
$self->render(
message => $message,
db_err => $db_err,
title => $self->lang_config->{'labels'}->{$self->language}->{'admin_console'}
);
}#---------------

#---------------------------------
sub user_admin {
#---------------------------------
my $c = shift;
my $language = $c->language;
my $template = $c->template;
my $table_users = $c->top_config->{'table'}->{'users'};
my %err_hash;
my $message;

#****************************************
if( $c->param('newsletter') eq 'no' ){
#****************************************
    my $id = $c->param('id');
    $c->menu->save($table_users, {'newsletter' => 'no'}, {'id' => $id});
    if( !$c->session('client') ){
        return $c->redirect_to( $c->url_for('/authentication')->query(
                                                        redirect_to => '/'
                                                       )
                   );
    }
}#*********

$c->redirect_to('/');
}#---------------
1;