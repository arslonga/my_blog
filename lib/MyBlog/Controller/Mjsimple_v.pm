package MyBlog::Controller::Mjsimple_v;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode url_unescape);
use RubricList;
use MyBlog::CommentForm;
use MyBlog::AnswerForm;
use MyBlog::CommentsTree;

#----------------------------------
sub archive{
#----------------------------------
my $self = shift;
return Archive->year_month($self);
}#--------------

#----------------------------------
sub main{
#----------------------------------
my($c) = @_;
my $url_mod = $c->routine_model->url_modif($c);

my $language = $c->language;
my $templ = lc($c->template).'/main';
my $table_archive_menu = $c->top_config->{'table'}->{'archive_menu'};
my($title_actual, $message, $title_alias, $title, $menu, $description, $keywords, 
   $list_enable, $tw_og, $top_chapter);

my $ref_article_proper = ArticleProper->new->article_proper($c, 'index');   
my $url_chaptr = $ref_article_proper->{'url_chaptr'};
my $table = $ref_article_proper->{'table'}; # level of menu

($title_alias, $title, $menu, $list_enable, 
$description, $keywords) = $c->menu->find($table, ['title_alias', 'title', 'menu', 'list_enable', 'description', 'keywords' ], 
                                               {'url' => $url_mod})->list;
                                               
my $content = $c->menu->find( $title_alias, ['*'], {}, {-desc => 'curr_date'} )->hashes;
$title_actual = $content->[0]->{'head'};

my $archive_menu = $c->menu->find( $table_archive_menu, ['menu'], {'url' => 'common'} )->list;
my($ref_id_name_rubric, $ref_rubr_id_count, $exist_rubr_numb) = RubricList->rubric_list($c);

$c->render(
template => $templ,
language => $language,
menu => $menu,
archive_menu => $archive_menu,
title_alias => $title_alias,
content => $content,
description => $description || $content->[0]->{'description'},
keywords => $keywords || $content->[0]->{'keywords'},
tw_og => $tw_og || $content->[0]->{'tw_opengraph'},
url_mod => $url_mod,
title => $description || $content->[0]->{'description'},
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb
);
}#--------------

#----------------------------------
sub index{
#----------------------------------
my($c) = @_;
my $url_mod = $c->routine_model->url_modif($c);

my $language = $c->language;
my $templ = lc($c->template).'/index';
my $table_archive_menu = $c->top_config->{'table'}->{'archive_menu'};
my $table_comments = $c->top_config->{'table'}->{'comments'};
my($ref_pagination_attr, $limit_str, $count_response, $bread_crumbs, $title_actual,
   $comment_enable, $comments_tree, $comments_tree_proms, $message, $message_of_comment, 
   $current_page, $total_pages, $offset, $order_for_time,
   $title_alias, $title, $menu, $list_enable, $description, $keywords, $tw_og, $top_chapter);

my $ref_article_proper = ArticleProper->new->article_proper($c, 'index');   
my $bread_crumbs_indicr = $ref_article_proper->{'bread_crumbs'};
my $url_chaptr = $ref_article_proper->{'url_chaptr'};
my $table = $ref_article_proper->{'table'}; # level of menu

($title_alias, $title, $menu, $list_enable, 
$description, $keywords, $order_for_time) = 
$c->menu->find($table, ['title_alias', 'title', 'menu', 'list_enable', 'description', 'keywords', 'order_for_time' ], 
                       {'url' => $url_mod})->list;

#============================
#if(!$title_alias){
#    return $c->render( template => 'not_found' );
#}
#============================
my $content = $c->menu->find( $title_alias, ['*'], {}, {-desc => 'curr_date'} )->hashes;
$comment_enable = $content->[0]->{'comment_enable'};

#======================================================

#======================================================

#********************************
if($list_enable eq 'yes'){
#********************************
    ($ref_pagination_attr, $current_page, $limit_str, $offset) = $c->routine_model->pagination_attr( $c, 'pagination_attr_file' );
    my $action = 'find_'.$order_for_time.'_'.$c->db_driver;    
    $total_pages = int( (scalar @$content)/$limit_str );
    $total_pages = $total_pages + 1 if( (scalar @$content)%$limit_str );
    $content = $c->menu->$action( $title_alias, $limit_str, $offset); 
}#********

my $page_id = $content->[0]->{'id'};
$title_actual = $title;
if($list_enable eq 'no'){
    $title_actual = $content->[0]->{'head'};
}

#************************************
if($content->[0]->{'comment_enable'} eq 'yes'){
#************************************
    $count_response = $c->menu->find( $table_comments, 
                                      ['count(page_id)'], 
                                      {
                                       'page_id' => $page_id, 
                                       'table_name' => $title_alias
                                      } 
                                    )->list;
    ($message_of_comment, $comments_tree) = $c->routine_model->comments($c, $table, $title_alias, $page_id);
}#**************

if($bread_crumbs_indicr){
    my $top_level = 'level'.(substr($table, -1, 1) - 1);
    $top_chapter = $c->menu->find( $top_level, ['title'], {'title_alias' => (split(/\//, $url_chaptr))[1]} )->list;
$bread_crumbs=<<BRCR;
<ol class="breadcrumb" id="breadcrmb">
  <li class="active">$top_chapter</li>
  <li class="active">$title</li>
</ol>
BRCR

}
my $archive_menu = $c->menu->find( $table_archive_menu, ['menu'], {'url' => 'common'} )->list;
my($ref_id_name_rubric, $ref_rubr_id_count, $exist_rubr_numb) = RubricList->rubric_list($c);

my %render_content = (
template => $templ,
comment_enable => $comment_enable,
comments_tree => $comments_tree,
current_page => $current_page,
total_pages => $total_pages,
pagination_attr => $ref_pagination_attr,
message_of_comment => $message_of_comment,
language => $language,
bread_crumbs => $bread_crumbs,
menu => $menu,
archive_menu => $archive_menu,
title_alias => $title_alias,
content => $content,
description => $description || $content->[0]->{'description'},
keywords => $keywords || $content->[0]->{'keywords'},
tw_og => $tw_og || $content->[0]->{'tw_opengraph'},
count_response => $count_response,
url_mod => $url_mod,
list_enable => $list_enable,
pagination_attr => $ref_pagination_attr,
title => $title_actual,
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb,
page_id => $page_id
);
$c->render(
    %render_content
);
}#--------------

#----------------------------------
sub article{
#----------------------------------
my($c) = @_;
my $ref_article_proper;
my $language = $c->language;
my $template = $c->template;
my $templ = lc($template).'/viewarticle';
my $url = $c->req->url;
if( scalar split(/\//, $url) <= 4 ){
    $ref_article_proper = ArticleProper->new->article_proper($c, 'article');
}else{
    $ref_article_proper = ArticleProper->new->article_proper($c, 'article_sub');
}

my $table_comments = $c->top_config->{'table'}->{'comments'};
my $table_archive_menu = $c->top_config->{'table'}->{'archive_menu'};
my $table = $ref_article_proper->{'table'};
my $id = $ref_article_proper->{'id'};
my $url_chaptr = $ref_article_proper->{'url_chaptr'};
my $bread_crumbs_indicr = $ref_article_proper->{'bread_crumbs'};
my($url_data, $comment_enable, $comments_tree, $comments_tree_proms, $message, 
   $top_chapter, $title_alias, $title, $menu, $bread_crumbs, $list_enable, $message_of_comment);
my $count_response = 0;

($title_alias, $title, $menu, $list_enable) = $c->menu->find( $table, ['title_alias', 'title', 'menu', 'list_enable'], {'url' => $url_chaptr} )->list;
my $content = $c->menu->find($title_alias, ['*'], {'id' => "$id"}, {-desc => 'curr_date'} )->hashes;
$url_data = $content->[0]->{'url'};
$comment_enable = $content->[0]->{'comment_enable'};

#============================
if($url ne $url_data){
    return $c->render(
    template => 'not_found'
    );
}
#============================

my($id_prev, $prev_head, $prev_url) = $c->db_table->prev_pag($c, $title_alias, $id, $content->[0]->{'curr_date'});
my($id_next, $next_head, $next_url) = $c->db_table->next_pag($c, $title_alias, $id, $content->[0]->{'curr_date'});

#************************************************
if( $comment_enable eq 'yes' ){
#************************************************
    $count_response = $c->menu->find( $table_comments, 
                                         ['count(page_id)'], 
                                         {
                                          'page_id' => $content->[0]->{'id'}, 
                                          'table_name' => $title_alias
                                         } 
                                         )->list;
    ($message_of_comment, $comments_tree) = $c->routine_model->comments($c, $table, $title_alias, $id);
}#*************

if($bread_crumbs_indicr){
    my $top_level = 'level'.(substr($table, -1, 1) - 1);
    $top_chapter = $c->menu->find( $top_level, ['title'], {'title_alias' => (split(/\//, $url_chaptr))[1]} )->list;
$bread_crumbs=<<BRCR;
<ol class="breadcrumb" id="breadcrmb">
  <li class="active">$top_chapter</li>
  <li><a href="$url_chaptr" class="breadcr_href">$title</a>
  </li>
</ol>
BRCR

}
EN:
my $archive_menu = $c->menu->find($table_archive_menu, ['menu'], {'url' => 'common'})->list;
my($ref_id_name_rubric, $ref_rubr_id_count, $exist_rubr_numb) = RubricList->rubric_list($c);

my %render_content = (
template => $templ,
templ => lc($c->template),
message => "",
message_of_comment => $message_of_comment,
comment_enable => $comment_enable,
language => $language,
bread_crumbs => $bread_crumbs,
menu => $menu,
archive_menu => $archive_menu,
title_alias => $title_alias,
content => $content,
description => $content->[0]->{'description'},
keywords => $content->[0]->{'keywords'},
tw_og => $content->[0]->{'tw_opengraph'},
id_head_prev => {'id' => $id_prev, 'head' => $prev_head, 'url' => $prev_url},
id_head_next => {'id' => $id_next, 'head' => $next_head, 'url' => $next_url},
comments_tree => $comments_tree,
count_response => $count_response,
redirect_to => $url,
list_enable => 'no',
title => $content->[0]->{'head'},
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb
);
$c->render(
    %render_content
);
}#--------------

#----------------------------------
sub url_for_search{
#----------------------------------
my($self, $url, $id, $literal_ident, $list_enable) = @_;

my $url_mod = $url; $url_mod = "" if($url eq '/');
my $url_for_search = $url_mod.'/'.$id.'/'.$literal_ident;
$url_for_search = $url if $list_enable ne 'yes';

return $url_for_search;
}#--------------

#----------------------------------
sub del_chapter {
#----------------------------------
my($self, $c, $max_level) = @_;
my $template = $c->template;
require $c->template.'/DataExplore.pm';

my $title_alias = $c->param('title_alias');
my $level = $c->param('level');

DataExplore->del_chapter($c, $title_alias, $level, $max_level);
}#--------------
1;