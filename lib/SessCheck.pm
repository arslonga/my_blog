package SessCheck;
#use Mojo::Base 'Mojolicious::Controller';
use Mojo::Base -base;
use Mojo::Util qw(trim);

#-------------------------------------
sub admin {
#-------------------------------------
my($c, $self) = @_;
my $table_access = $self->top_config->{'adm'}->{'table'}->{'access'}->{'name'};
my $checker;

my $access_row = $self->menu->find($table_access, '*')->hash;
my $login   = $access_row->{admin};
my $passwrd = $access_row->{password};

if( $self->session('admin') && 
    ($self->session('admin')->[0] eq $login && 
    $self->session('admin')->[1] eq $passwrd) ){ 
    $checker = 1;
}
return defined $checker;
}#---------------

#-------------------------------------
sub client {
#-------------------------------------
my($c, $self, $client_id) = @_;
my $table_users = $self->top_config->{'table'}->{'users'};
my $checker;

if( $client_id && $self->session('client')->[1] eq 
    $self->menu->find( $table_users, ['login'], {id => $client_id} )->list ){ 
    $checker = 1;
}

return defined $checker;
}#---------------

#---------------------------------
sub check_config{
#---------------------------------
my($c, $self, $key, $access_check_config) = @_;
my $app = (split(/::/, $self))[0]->new;

$c = {
         'db_driver' => sub{ my($checker, $dbdriver_configured_status); 
                             eval{
                             $dbdriver_configured_status = $self->slurp('conf/'.$app->language.'/'.$self->top_config->{'dbdriver_configured_status_file'}); 
                             };
                             if( $self->req->body_params->param('request') ne 'change_db' ||
                                 ( $dbdriver_configured_status && 
                                 $dbdriver_configured_status ne $app->config('secrets')->[0] ) ){
                                 undef $checker;
                             }else{
                                 $checker = 1;
                             }
                           return defined $checker;
                           },
                           
         'dbaccess' => sub{ my($checker, $db_configured_status); 
                             eval{
                             $db_configured_status = trim( $self->slurp('conf/'.$app->language.'/'.$self->top_config->{'db_configured_status_file'}) );
                             };
                             if( $self->req->body_params->param('request') ne 'reconf_db' ||
                                 ( $db_configured_status && 
                                 $db_configured_status ne $app->config('secrets')->[0] ) ){
                                 undef $checker;
                             }
                             if( $db_configured_status eq $app->config('secrets')->[0] && 
                                 $self->req->body_params->param('request_reconf') eq 'reconf_db' ||
                                 !$db_configured_status ){
                                 $checker = 1;
                             }
                           return defined $checker;
                           },
                           
         'access' => sub{ my($checker, $access_configured_status); 
                          eval{
                          $access_configured_status = $self->slurp('conf/'.$app->language.'/'.$self->top_config->{'access_configured_status_file'}); 
                          };
                          if( $access_configured_status eq $app->config('secrets')->[0] ){
                            $checker = 1;
                            if($self->req->body_params->param('change_access') ne 'jolimocious'){
                                undef $checker;
                            }else{
                                $checker = 1;
                            }
                          }
                          if( $access_configured_status && 
                              $access_configured_status ne $app->config('secrets')->[0] ){
                              undef $checker;
                          }
                          if( !$access_configured_status || 
                               $access_configured_status eq $app->config('secrets')->[0] ){
                              $checker = 1;
                          }
                        return defined $checker;
                        },
                        
    'access_next' => sub{ 
                         my $tmp_content = $self->slurp( 'conf/'.$self->language.'/tmp' );
                         if( $access_check_config && !$self->req->body_params->param('change_access') && $tmp_content ne 'yes' ){
                            $self->redirect_to('admin');
                         }
                         if( $access_check_config && $self->req->body_params->param('change_access') ){
                            if( $self->req->body_params->param('change_access') ne 'jolimocious' ){
                                $self->redirect_to('admin');
                            }
                         }
                         return 1;
                        }
};

return $c->{$key}->();
}#--------

1;