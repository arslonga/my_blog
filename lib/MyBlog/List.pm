package MyBlog::List;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use MyBlog::RssArticles;
use DB::Delete;
use DeleteFile;
use RewriteImage;
use LiteralIdent;
use EveryParam;
use ImageFeatr;

#---------------------------------
sub list_content {
#---------------------------------
my $self = shift;

my(%err_hash, $message);
my $language = $self->language;
my $table = $self->param('title_alias');

my($level, $level_id, $kind_of_publ) = $self->menu->find( $table, ['level', 'level_id', 'template'] )->list;
my($title_chapter, $list_enable, $url, $order_for_time) = $self->menu->find($level, 
['title', 'list_enable', 'url', 'order_for_time'], 
{id => $level_id})->list;

#*********************************
if( $self->param('add') ){
#*********************************
    my $head = $self->regexp->title_clean( trim( $self->param('head') ) ) || 
                                           $self->lang_config->{'new_page_content'}->{$language};
    my $literal_ident = LiteralIdent->literal_for_url($self, $head);
    my($level, $level_id, $template) = 
    $self->menu->find( $table, 
                       ['level', 'level_id', 'template'] 
                     )->list;
    my($list_enable, $url) = 
    $self->menu->find( $level, 
                       ['list_enable', 'url'], 
                       {id => $level_id} 
                     )->list;
                     
    my $last_insert_id = 
    $self->menu->create( $table, 
                         {
                          'level'      => $level,
                          'level_id'   => $level_id,
                          'rubric_id'  => 0,
                          'curr_date'  => $self->db_table->now($self),
                          'head'       => $head,
                          'url'        => '',
                          'announce'   => $self->lang_config->{'new_page_content'}->{$language},
                          'content'    => $self->lang_config->{'new_page_content'}->{$language},
                          'author_id'  => 0,
                          'template'   => $template,
                          'comment_enable' => 'no',
                          'liked'     => 0,
                          'unliked'   => 0
                         }
               );
               
my $url_for_data = 
$self->routine->url_for_search( $url, $last_insert_id, $literal_ident, $list_enable );
$self->menu->save( $table, 
                   {'url' => $url_for_data}, 
                   {'id' => $last_insert_id} 
                 );

$self->redirect_to( 
$self->url_for("/list_content_manage")->
query(
      title_alias => $table,
      title    => $self->param('title')
     )
);
}#**********

if($self->param('order_for_time')){
    $order_for_time = $self->param('order_for_time');
    $self->menu->save( $level, 
                       {'order_for_time' => $self->param('order_for_time')}, 
                       {id => $level_id}
                     );
}
my $data_ref = $self->menu->find( $table, 
                                  ['*'], 
                                  {}, 
                                  {-asc => 'curr_date'} 
                                )->hashes;

$self->render(
data_ref => $data_ref,
order_for_time => $order_for_time,
language => $language,
title_alias => $table,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
#title => $self->param('title')
title => $title_chapter
);
}#------------

#---------------------------------
sub user_list_content {
#---------------------------------
my $self = shift;

my($message);
my $language = $self->language;

my $table = $self->param('title_alias');
my $user_id = $self->session('client')->[0];
my $login = $self->session('client')->[1];

#*********************************
if( $self->param('add') ){
#*********************************
    my $head = $self->regexp->title_clean( trim( $self->param('head') ) ) || 
    $self->lang_config->{'new_page_content'}->{$language};
    
    my $literal_ident = LiteralIdent->literal_for_url($self, $head);
    my( $level, 
        $level_id, 
        $template ) = $self->menu->find( $table, 
                                         ['level', 'level_id', 'template'] 
                                       )->list;
    my( $list_enable, 
        $url ) = $self->menu->find( $level, 
                                    ['list_enable', 'url'], 
                                    {id => $level_id}
                                  )->list;

my $last_insert_id = $self->menu->create($table, {
                                    'level'      => $level,
                                    'level_id'   => $level_id,
                                    'rubric_id'  => 0,
                                    'curr_date'  => $self->db_table->now($self),
                                    'head'       => $head,
                                    'url'        => '',
                                    'announce'   => $self->lang_config->{'new_page_content'}->{$language},
                                    'content'    => $self->lang_config->{'new_page_content'}->{$language},
                                    'author_id'  => $self->session('client')->[0] || 0,
                                    'template'   => $template,
                                    'comment_enable' => 'no',
                                    'liked'     => 0,
                                    'unliked'   => 0
                                   }
               );
my $url_for_data = $self->routine->url_for_search( $url, 
                                                   $last_insert_id, 
                                                   $literal_ident, 
                                                   $list_enable 
                                                 );
$self->menu->save( $table, {'url' => $url_for_data}, {'id' => $last_insert_id} );
$self->redirect_to( $self->url_for("/user_list_content_manage")
->query(
         title_alias => $table,
         title    => $self->param('title')
       )
);
}#**********
ENDD:
my $data_ref = $self->menu->find( $table, 
                                  ['*'], 
                                  {'author_id' => $user_id}, 
                                  {-desc => 'curr_date'} 
                                )->hashes;

$self->render(
client => $self->session('client'),
data_ref => $data_ref,
language => $language,
title_alias => $table,
user_id => $user_id,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->param('title')
);
}#------------

#---------------------------------
sub article {
#---------------------------------
my $self = shift;

my(%err_hash, $data_ref, $message);
my $language = $self->language;
my $search_table = $self->top_config->{'table'}->{'search_artcl'};
my $table_comments = $self->top_config->{'table'}->{'comments'};
my $article_required_fields = $self->top_config->{'adm'}->{'article_required_fields'};
my $redirect_to = 'article_manage';
my $action = 'decode_'.$self->db_driver;

my $type_of_upload          = $self->top_config->{'type_of_upload'};
my $template_for_upload     = $self->top_config->{'template_for_type_upload'};
my $tables_of_sourse_upload = $self->top_config->{'tables_of_upload'};
my $table_rubric = $self->top_config->{'table'}->{'rubric'};
my($search_id, $data_in_search, $literal_ident, $author_id_for_update);
my $promise = Mojo::Promise->new;

my $table = $self->param('title_alias');
my $id = $self->param('id') || $self->menu->find( $table, ['id'], 
                                                  {level_id => $self->param('level_id')} 
                                                )->list;

$author_id_for_update = $self->menu->find( $table, ['author_id'], {'id' => $id} )->list;

my($level, $level_id, $head) = $self->menu->find( $table, 
                                                  ['level', 'level_id', 'head'], 
                                                  {id => $id} 
                                                )->list;
my($title_chapter, $list_enable, $url) = $self->menu->find( $level, 
                                                            ['title', 'list_enable', 'url'], 
                                                            {id => $level_id} 
                                                          )->list;

#****************************************    
if($self->param('delete')){
#****************************************
DB::Delete->delete_article($self, $list_enable, $table, $id, $level);
$self->redirect_to('menu_manage');
}#***********

#*******************************************************    
if( $self->param('edit') ){
#*******************************************************
my $v = $self-> _validation( $self->top_config->{'adm'}->{'article_required_fields'} );
    goto ENA if $v->has_error;
    
DeleteFile->delete( $self );

my $content  = trim($self->param('cont_text'));
my $head     = $self->regexp->title_clean( trim($self->param('head')) );
my $announce = trim( $self->param('announce') );
my $description =  $self->regexp->name_clean( trim( $self->param('description') ) );
my $keywords =  $self->regexp->keyword_clean( trim( $self->param('keywords') ) );

$literal_ident = LiteralIdent->literal_for_url( $self, $head );
# Визначаємо url для таблиці індексування в залежності від шаблона і особливостей сторінки $list_enable #############
my $url_for_data = $self->routine->url_for_search($url, $id, $literal_ident, $list_enable);

    if( $self->param('lead_img') ){
        ImageFeatr->lead_image($self, $table);
    }
    ImageFeatr->alt_attr($self);

    $self->menu->save( $table, {
                        #description => $self->regexp->keyword_clean( trim($self->param('description')) ),
                        #keywords  => $self->regexp->keyword_clean( trim($self->param('keywords')) ),
                        description => $description,
                        keywords  => $keywords,
                        tw_opengraph => trim($self->param('tw_opengraph')),
                        head      => $head,
                        url       => $url_for_data,
                        curr_date => trim($self->param('curr_date')),
                        rubric_id => $self->param('rubric') || 0,
                        lead_img  => $self->param('lead_img') || "",
                        announce  => $announce,
                        content   => $content,
                        author_id => $author_id_for_update,
                        comment_enable => $self->param('comment_enable')
                        }, {id => $id} );
                        
    $self->menu->save( $table_comments, 
                       {url => $url_for_data}, 
                       {page_id => $id, table_name => $table} 
                     );
                        
    # Clean text for indexing
    $content = $self->clean_text( $content );
                        
    eval{                    
    ($search_id, $data_in_search) = $self->menu->find( $search_table, 
                                                       ['id', 'search_text'], 
                                                       {
                                                        table_name => $table, 
                                                        page_id => $id
                                                       }
                                                     )->list;
    };
    
    my $search_text = lc($head).'. '.lc($description).'. '.lc($content);
    my $search_text_decode = encode('utf8', $search_text);

    # Indexing post ########################################
    if(!$data_in_search){
        $self->menu->create( $search_table, 
                             {
                              url         => $url_for_data,
                              table_name  => $table,
                              page_id     => $id,
                              head        => $head,
                              description => $description,
                              search_text => $search_text
                             }
                           );
    }else{
        $self->menu->save( $search_table, 
                           {
                            url         => $url_for_data,
                            table_name  => $table,
                            page_id     => $id,
                            head        => $head,
                            description => $description,
                            search_text => $search_text
                           }, 
                           {table_name => $table, page_id => $id}
                         );
    }###########################################################

$promise->then(sub {
        Archive->archive_menu( $self ),
        MyBlog::RssArticles->rss_articles( $self ),
    },
    sub{
        say "Rejected with: @_";
    }
)->catch( sub { say "Error: @_" } );
$promise->resolve;
$promise->wait;

$self->redirect_to( $self->url_for("/article_manage")->
                    query(
                          title_alias => $table,
                          id          => $id,
                          time        => time()
                         )
                  ); 
}#***************
ENA:
$data_ref = $self->menu->find( $table, ['*'], {id => $id} )->hashes;

my($ref_illustr, $ref_docs, $ref_media) = 
@{$self->db_table->media_data($self, $id, $table)};
my $id_rubric_ref = $self->menu->find( $table_rubric, ['*'], {}, 'id' )->hashes;

my $tw_og_sample = $self->slurp('templates/list/tw_og_sample');
$tw_og_sample =~ s/\"/\&quot\;/g;

$self->render(
language => $language,
title_chapter => $title_chapter,
title_alias => $table,
tw_og_sample => $tw_og_sample,
list_enable => $list_enable,
id => $id,
url => $url,
list_enable => $list_enable,
redirect_to => $redirect_to,
head => $data_ref->[0]->{'head'},
rubric_list => $id_rubric_ref,
lead_img => $data_ref->[0]->{'lead_img'},
content => $data_ref,
type_of_upload => $type_of_upload,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->$action( $data_ref->[0]->{'head'} ),
illustr_arr => $ref_illustr,
docs_arr    => $ref_docs,
media_arr   => $ref_media,
);
}#------------

#---------------------------------
sub user_article {
#---------------------------------
my $self = shift;

my($data_ref, $message);
my $language = $self->language;
my $search_table = $self->top_config->{'table'}->{'search_artcl'};
my $table_comments = $self->top_config->{'table'}->{'comments'};
my $redirect_to = 'user.article_manage';
my $user_id = $self->session('client')->[0];
my $action = 'decode_'.$self->db_driver;

my $type_of_upload          = $self->top_config->{'type_of_upload'};
my $template_for_upload     = $self->top_config->{'template_for_type_upload'};
my $tables_of_sourse_upload = $self->top_config->{'tables_of_upload'};
my $table_rubric = $self->top_config->{'table'}->{'rubric'};
my($search_id, $data_in_search, $literal_ident);
my $promise = Mojo::Promise->new;

my $table = $self->param('title_alias');
my $id    = $self->param('id') || 
$self->menu->find( $table, ['id'], {level_id => $self->param('level_id')} )->list;

my($level, $level_id, $head) = $self->menu->find( $table, 
                                                  ['level', 'level_id', 'head'], 
                                                  {id => $id}
                                                )->list;
my($title_chapter, $list_enable, $url) = $self->menu->find( $level, 
                                                            ['title', 'list_enable', 'url'], 
                                                            {id => $level_id}
                                                          )->list;

#*******************************************************    
if( $self->param('edit') ){
#*******************************************************
my $v = $self-> _validation( $self->top_config->{'adm'}->{'article_required_fields'} );
    goto ENU if $v->has_error;
    
DeleteFile->delete($self);

my $content = trim($self->param('cont_text'));
my $head    = $self->regexp->title_clean( trim($self->param('head')) );
my $announce = trim( $self->param('announce') );
my $description =  $self->regexp->name_clean( trim( $self->param('description') ) );
my $keywords =  $self->regexp->keyword_clean( trim( $self->param('keywords') ) );

$literal_ident = LiteralIdent->literal_for_url($self, $head);
# Визначаємо url для таблиці індексування в залежності від шаблона і особливостей сторінки $list_enable #############
my $url_for_data = $self->routine->url_for_search( $url, $id, $literal_ident, $list_enable );

    if( $self->param('lead_img') ){
        ImageFeatr->lead_image($self, $table);
    }
    ImageFeatr->alt_attr($self);
   
   $self->menu->save( $table, {
                        description => $description,
                        keywords  => $keywords,
                        tw_opengraph => trim($self->param('tw_opengraph')),
                        head      => $head,
                        url       => $url_for_data,
                        curr_date => trim($self->param('curr_date')),
                        rubric_id => $self->param('rubric') || 0,
                        lead_img  => $self->param('lead_img') || "",
                        announce  => $announce,
                        content   => $content,
                        author_id => $user_id,
                        comment_enable => $self->param('comment_enable')
                        }, {id => $id} );
                        
    $self->menu->save( $table_comments, {url => $url_for_data}, {page_id => $id, table_name => $table} );
                        
    $content = $self->clean_text( $content );
                        
    eval{                    
    ($search_id, $data_in_search) = $self->menu->find( $search_table, 
                                                       ['id', 'search_text'], 
                                                       { 
                                                        table_name => $table, 
                                                        page_id => $id
                                                       }
                                                     )->list;
    };
    
    my $search_text = lc($head).'. '.lc($description).'. '.lc($content);
    # Indexing post ########################################
    if(!$data_in_search){
        $self->menu->create( $search_table, 
                             {
                              url         => $url_for_data,
                              table_name  => $table,
                              page_id     => $id,
                              head        => $head,
                              description => $description,
                              search_text => $search_text
                             }
                           );
    }else{
        $self->menu->save( $search_table, 
                           {
                            url         => $url_for_data,
                            table_name  => $table,
                            page_id     => $id,
                            head        => $head,
                            description => $description,
                            search_text => $search_text
                           }, 
                           {table_name => $table, page_id => $id}
                         );
    }###########################################################
$promise->then( sub {
        Archive->archive_menu( $self ),
        MyBlog::RssArticles->rss_articles( $self ),
    },
    sub{
        say "Rejected with: @_";
    }
)->catch( sub { say "Error: @_" } );
$promise->resolve;
$promise->wait;

$self->redirect_to( $self->url_for("/user.article_manage")->
                    query(
                          title_alias => $table,
                          id          => $id,
                          time        => time()
                         )
                  ); 
}#***************
ENU:
$data_ref = $self->menu->find( $table, 
                               ['*'], 
                               {'id' => "$id", 'author_id' => $user_id}
                             )->hashes;

my($ref_illustr, $ref_docs, $ref_media) = @{$self->db_table->media_data($self, $id, $table)};
my $id_rubric_ref = $self->menu->find( $table_rubric, ['*'], {}, 'id' )->hashes;

my $tw_og_sample = $self->slurp('templates/list/tw_og_sample');
$tw_og_sample =~ s/\"/\&quot\;/g;

$self->render(
client => $self->session('client'),
language => $language,
title_chapter => $title_chapter,
title_alias => $table,
tw_og_sample => $tw_og_sample,
list_enable => $list_enable,
id => $id,
url => $url,
list_enable => $list_enable,
redirect_to => $redirect_to,
head => $data_ref->[0]->{'head'},
rubric_list => $id_rubric_ref,
lead_img => $data_ref->[0]->{'lead_img'},
content => $data_ref,
type_of_upload => $type_of_upload,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->$action( $data_ref->[0]->{'head'} ),
illustr_arr => $ref_illustr,
docs_arr    => $ref_docs,
media_arr   => $ref_media,
);
}#------------
1;