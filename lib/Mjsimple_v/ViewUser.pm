package Mjsimple_v::ViewUser;
use Mojo::Base 'Mojolicious::Controller';
use RubricList;
use CommentsRef;

#---------------------------
sub user_comments {
#---------------------------
my $self = shift;
my $language = $self->language;
my $templ = lc($self->template).'/user_comments';
my $table_archive_menu = $self->top_config->{'table'}->{'archive_menu'};
my $table_users = $self->top_config->{'table'}->{'users'};
my(%tab_name_page_id, @page_head, $page_head, $message);
my $user_id = $self->param('id');

my $user_name = $self->menu->find( $table_users, ['login'], {'id' => $user_id} )->list;
$page_head = CommentsRef->comments_ref_user($self, $user_name);

my $menu = RewrMenu->active_rewrite($self);
my $archive_menu = $self->menu->find( $table_archive_menu, ['menu'], {'url' => 'common'} )->list;
my($ref_id_name_rubric, $ref_rubr_id_count, $exist_rubr_numb) = RubricList->rubric_list($self);

$self->render(
template => $templ,
list_enable => '',
comment_enable => 'no',
tw_og => '',
language => $language,
message => $message,
menu => $menu,
user_id => $user_id,
user_name => $user_name,
page_head => [@$page_head],
title => $user_name,
description => $user_name.'. '.$self->lang_config->{'labels'}->{$language}->{'responses'},
keywords => $user_name.'. '.$self->lang_config->{'labels'}->{$language}->{'responses'},
archive_menu => $archive_menu,
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb
);
}#-------------

#------------------------------------
sub user_posts {
#------------------------------------
my $self = shift;
my $language = $self->language;
my $templ = lc($self->template).'/user_posts';
my $table_archive_menu = $self->top_config->{'table'}->{'archive_menu'};
my $table_users = $self->top_config->{'table'}->{'users'};
my(%tab_name_posts, @page_head, $page_head, $message, @posts);
my $user_id = $self->param('id');

my $user_name = $self->menu->find( $table_users, ['login'], {'id' => $user_id} )->list;
my @title_alias = @{TitleAliasList->title_alias_list($self)};

foreach my $curr_table(@title_alias){
    @posts = $self->menu->find( $curr_table, ['id', 'curr_date', 'head', 'announce', 'url'], 
                                      {'author_id' => $user_id}, 
                                      {-desc => 'curr_date'} )->arrays;
    $tab_name_posts{$curr_table} = [@posts] if(@posts);
}
foreach my $table_name(sort keys %tab_name_posts){
    foreach(@{$tab_name_posts{$table_name}}){
    }
}
    
my $menu = RewrMenu->active_rewrite($self);
my $archive_menu = $self->menu->find( $table_archive_menu, ['menu'], {'url' => 'common'} )->list;
my($ref_id_name_rubric, $ref_rubr_id_count, $exist_rubr_numb) = RubricList->rubric_list($self);

$self->render(
template => $templ,
list_enable => '',
comment_enable => 'no',
tw_og => '',
language => $language,
message => $message,
menu => $menu,
user_id => $user_id,
user_name => $user_name,
tab_name_posts => {%tab_name_posts},
title => $user_name,
description => $user_name.'. '.$self->lang_config->{'posts'}->{$language},
keywords => $user_name.'. '.$self->lang_config->{'posts'}->{$language},
archive_menu => $archive_menu,
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb
);
}#-------------
1;