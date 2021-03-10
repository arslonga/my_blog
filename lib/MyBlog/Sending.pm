package MyBlog::Sending;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use EveryParam;

#---------------------------------
sub sending_kinds {
#---------------------------------
my $self = shift;
my $language = $self->language;
my $kind_of_sending = $self->top_config->{'kind_of_sending'};

$self->render(
language => $language,
kind_of_sending => $kind_of_sending,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'sending'}->{$language},
head => $self->lang_config->{'sending'}->{$language}
);
}#---------------

#---------------------------------
sub text_sending {
#---------------------------------
my $self = shift;
my $language = $self->language;
my $list_of_numb_for_sending = $self->top_config->{'numb_for_sending'};
my $numb_for_sending_artcl_file = $self->top_config->{'numb_for_sending_artcl_file'};

if($self->param('numb_for_send')){
    $self->spurt($self->param('numb_for_send'), $numb_for_sending_artcl_file);
}
my $exist_numb_for_sending = $self->slurp( $numb_for_sending_artcl_file );

$self->render(
language => $language,
list_of_numb_for_sending => $list_of_numb_for_sending,
exist_numb_for_sending => $exist_numb_for_sending,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'sending'}->{$language},
head => $self->lang_config->{'sending'}->{$language}
);
}#---------------

#---------------------------------
sub text_sending_select {
#---------------------------------
my $self = shift;
my $language = $self->language;
my $list_of_numb_for_sending = $self->top_config->{'numb_for_sending'};
my $exist_numb_for_sending = $self->slurp( $self->top_config->{'numb_for_sending_artcl_file'} );
my(%table_url, %table_title, @url, $item);

my $title_alias_title = TitleAliasList->title_alias_title_list($self);
foreach my $table_title(@$title_alias_title){
    my($table, $title) = split(/\|/, $table_title);
    my $result = $self->db->query( qq[SELECT id, head, announce, url FROM $table 
                                     ORDER BY curr_date DESC LIMIT ? ], 
                                     $exist_numb_for_sending );
    while(my($id, $head, $announce, $url) = $result->list){
        push @url, {'id' => $id, 'head' => $head, 'announce' => $announce, 'url' => $url};
    }
    $table_url{$table} = [@url];
    $table_title{$table} = $title;
    @url = ();
}

$self->render(
language => $language,
list_of_numb_for_sending => $list_of_numb_for_sending,
exist_numb_for_sending => $exist_numb_for_sending,
title_alias_title => $title_alias_title,
table_url => {%table_url},
table_title => {%table_title},
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'sending'}->{$language},
head => $self->lang_config->{'sending'}->{$language}
);
}#---------------

#---------------------------------
sub text_sending_users {
#---------------------------------
my $self = shift;

my $language = $self->language;
my $template = $self->template;
my $table_users = $self->top_config->{'table'}->{'users'};
my($db, $users, $selected_items, @item_sending);

@item_sending = EveryParam->get_array_sending_opt( $self, 'item_sending' );

#*************************************
if(@item_sending){
#*************************************
    $selected_items = join('|', @item_sending);
    $users = $self->menu->find( $table_users, 
                                ['id', 'login', 'email'], 
                                {'view_status' => 'yes', 'newsletter' => 'yes'}, 
                                {-desc => 'curr_date'} 
                              )->hashes;
}#*************

$self->render(
language => $language,
users => $users,
selected_items => $selected_items,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'sending'}->{$language},
head => $self->lang_config->{'sending'}->{$language}
);
}#---------------

#---------------------------------
sub text_sending_tosend {
#---------------------------------
use ParseMsg;
use MyBlog::Mail;
my $self = shift;
my $action = 'decode_'.$self->db_driver;

my $language = $self->language;
my $template = $self->template;
my $table_users = $self->top_config->{'table'}->{'users'};
my $msg_type2 = 'newsletter_add';
my($users, $selected_items, @users_id);
my $body_newsletter = decode('utf8', 
ParseMsg->msg_newsletter_add($self, $self->top_config->{'msg_type'}->{$msg_type2})
);

@users_id = EveryParam->get_array_sending_opt($self, 'user_id');

$selected_items = $self->param('selected_items');

my $sending_body = __PACKAGE__->sending_body($self, $selected_items);

foreach my $user_id(@users_id){
    my $sending_body_mod = $self->$action( $sending_body );
    my($email, $login) = $self->db->select( $table_users, 
                                            ['email', 'login'], 
                                            {'id' => $user_id}
                                          )->list;
    my $cancel_link = $self->protocol.'://'.
                      $self->req->url->to_abs->host.
                      '/user.admin?newsletter=no&id='.
                      $user_id;
    $sending_body_mod.="\n".$body_newsletter."\n".$cancel_link;
    # Розсилка на адреси масиву користувачів
    #MyBlog::Mail->just_text($self->top_config->{'noreply_mail'}, $email, $self->menu->find( 'user_passw', ['email'] )->list,
    #                        $self ->lang_config->{'sending'}->{$language}.' '.$self->req->url->to_abs->host, #subject
    #                        "", $sending_body_mod);
    MyBlog::Mail->as_html( $self->top_config->{'noreply_mail'}, $email, 
                           $self->menu->find( 'user_passw', ['email'] )->list,
                           $self ->lang_config->{'sending'}->{$language}.' '.
                           $self->req->url->to_abs->host, #subject
                           $sending_body_mod
                         );
}

$self->redirect_to('sending_kinds');
}#---------------

#---------------------------------
sub sending_body {
#---------------------------------
my($self, $c, $selected_items) = @_;
my $sending_body;
my @selected = split(/\|/, $selected_items);

foreach my $table_id_article(@selected){
    my($table, $id) = split(/\=/, $table_id_article);
    my($url, $head, $announce) = $c->menu->find( $table, 
                                                 ['url', 'head', 'announce'], 
                                                 {'id' => $id} 
                                               )->list;
    $sending_body.=uc($head)."\n".
    $announce."\n".$c->protocol.'://'.
    $c->req->url->to_abs->host.$url."\n<br>".
    '----------------------------------------------------'."\n<br>";
}
return $sending_body;
}#-----------

#---------------------------------
sub html_sending {
#---------------------------------
my $self = shift;

my $language = $self->language;
my $template = $self->template;
my $html_sending_file = $self->top_config->{'html_sending_file'};
my $html_data = trim($self->param('html_data'));

if($html_data){
    $self->spurt( encode('utf8', $html_data), $html_sending_file );
}
my $html_sending_data = $self->slurp($html_sending_file);

$self->render(
language => $language,
html_sending_data => decode('utf8', $html_sending_data),
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'sending'}->{$language},
head => $self->lang_config->{'sending'}->{$language}
);
}#---------------

#---------------------------------
sub html_sending_users {
#---------------------------------
my $self = shift;

my $language = $self->language;
my $template = $self->template;
my $table_users = $self->top_config->{'table'}->{'users'};
my($db, $users, $selected_items, @item_sending);

$users = $self->menu->find( $table_users, 
                            ['id', 'login', 'email'], 
                            {'view_status' => 'yes', 'newsletter' => 'yes'}, 
                            {-desc => 'curr_date'} )->hashes;

$self->render(
language => $language,
users => $users,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'sending'}->{$language},
head => $self->lang_config->{'sending'}->{$language}
);
}#---------------

#---------------------------------
sub html_sending_tosend {
#---------------------------------
use ParseMsg;
use MyBlog::Mail;
my $self = shift;

my $language = $self->language;
my $template = $self->template;
my $html_sending_file = $self->top_config->{'html_sending_file'};
my $table_users = $self->top_config->{'table'}->{'users'};
my $msg_type2 = 'newsletter_add';
my(@users_id);
#my $body_newsletter = decode('utf8', ParseMsg->msg_newsletter_add($self, $self->top_config->{'msg_type'}->{$msg_type2}));
my $body_newsletter = ParseMsg->msg_newsletter_add($self, $self->top_config->{'msg_type'}->{$msg_type2});

@users_id = EveryParam->get_array_sending_opt($self, 'user_id');

# Creating a mailing body
my $sending_body = $self->slurp( $html_sending_file );

foreach my $user_id(@users_id){
    my $sending_body_mod = $sending_body;
    my($email, $login) = $self->db->select( $table_users, 
                                            ['email', 'login'], 
                                            {'id' => $user_id} 
                                          )->list;
    my $cancel_link = $self->protocol.'://'.$self->req->url->to_abs->host.
    '/user.admin?newsletter=no&id='.$user_id;
    $sending_body_mod.="\n".$body_newsletter."\n".$cancel_link;

    # Mailing to the addresses of the array of users
    MyBlog::Mail->as_html( $self->top_config->{'noreply_mail'}, $email, 
                           $self->menu->find('user_passw', ['email'])->list,
                           $self ->lang_config->{'sending'}->{$language}.' '.
                           $self->req->url->to_abs->host, #subject
                           $sending_body_mod);
}

$self->redirect_to('sending_kinds');
}#---------------
1;