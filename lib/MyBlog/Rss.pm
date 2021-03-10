package MyBlog::Rss;
use Mojo::Base 'Mojolicious::Controller';
use MyBlog::RssArticles;

#---------------------------
sub rss_setting {
#---------------------------
my $self = shift;
my $language = $self->language;
my $table_rss_setting = $self->top_config->{'table'}->{'rss_setting'};
my $table_rss_data = $self->top_config->{'table'}->{'rss_data'};
my $table_rubric = $self->top_config->{'table'}->{'rubric'};
my $list_of_artcl_numb = $self->top_config->{'artcl_numb_rss'};
my $rss_setting_required_fields = 
$self->top_config->{'adm'}->{'rss_setting_required_fields'};
my $message;

my $limit_links = $self->param('artcl_numb');

if($self->param('err_config')){
    $message = $self->lang_config->{'conf_rss_begin'}->{$language};
}
    
#*******************************************************    
if( $self->param('set_rss_descr') ){
#*******************************************************
my $v = $self-> _validation( $self->top_config->{'adm'}->{'rss_setting_required_fields'} );
    goto EN if $v->has_error;

my $title  = $self->menu->find($table_rss_setting, ['title'])->list;
if($title){
    $self->menu->save( $table_rss_setting, 
                       {
                        'title' => $self->param('title'), 
                        'description' => $self->param('description'),
                        'list_number' => $self->param('artcl_numb')
                       }, 
                       {'title' => $title}
                     );
}else{
     $self->menu->create( $table_rss_setting, 
                          {
                           'title' => $self->param('title'), 
                           'description' => $self->param('description'),
                           'list_number' => $self->param('artcl_numb')
                          }
                        );
}
$self->redirect_to('/rss_setting');
}#***********
my($title, $description, $list_number) = 
$self->menu->find( $table_rss_setting, 
                   ['title', 'description', 'list_number'] 
                 )->list;
goto EN if(!$title);

MyBlog::RssArticles->rss_articles($self);
MyBlog::RssArticles->rss_comments($self);

EN:
$self->render(
language => $language,
message => $message,
list_of_artcl_numb => $list_of_artcl_numb,
data_ref => $self->menu->find( $table_rss_setting, ['*'] )->hash,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'labels'}->{$language}->{'rss_setting'},
head => $self->lang_config->{'labels'}->{$language}->{'rss_setting'},
);
}#-------------

#------------------------------------
sub articles_feed {
#------------------------------------
my $self = shift;
$self->res->headers->content_type('text/xml');
$self->res->content->asset( 
Mojo::Asset::File->new( path => $self->top_config->{'rss_articles_path'} ) 
);
$self->rendered(200);
}#-----------

#------------------------------------
sub comments_feed {
#------------------------------------
my $self = shift;
$self->res->headers->content_type('text/xml');
$self->res->content->asset( 
Mojo::Asset::File->new( path => $self->top_config->{'rss_comments_path'} ) 
);
$self->rendered(200);
}#-----------
1;