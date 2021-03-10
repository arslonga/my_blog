package MyBlog::Sitemap;
use Mojo::Base 'Mojolicious::Controller';
use RubricList;

#---------------------------
sub sitemap {
#---------------------------
my $self = shift;
my $language = $self->language;
my $template = $self->template;
my $table_archive_menu = $self->top_config->{'table'}->{'archive_menu'};
my $action = 'encode_'.$self->db_driver;
my $message;

my $menu = RewrMenu->active_rewrite($self);
my($archive_menu) = $self->db->select( $table_archive_menu, 
                                       ['menu'], 
                                       {'url' => 'common'} )->list;
my($ref_id_name_rubric, $ref_rubr_id_count, $exist_rubr_numb) = RubricList->rubric_list($self);

$self->render(
template => lc($template).'/site_map',
comment_enable => 'no',
count_response => 0,
list_enable => '',
tw_og => '',
language => $language,
menu => $menu,
archive_menu => $archive_menu,
message => $message,
description => $self->lang_config->{'sitemap_description'}->{$language},
keywords => $self->lang_config->{'sitemap_keywords'}->{$language},
title => $self->lang_config->{'sitemap'}->{$language},
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb
);
}#-------------
1;
