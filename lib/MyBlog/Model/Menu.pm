package MyBlog::Model::Menu;
use Mojo::Base -base;
use base 'DB';
use Mojo::Promise;
#use Data::Dumper;
use Mojo::Util qw(trim encode decode);
use LiteralIdent;
use Mojo::Pg;
#use Mojo::mysql;
use MyBlog::Model::CommentCount;

has 'db';

#-------------------------
sub find {
#-------------------------
my $self = shift;
my $table = shift;
return $self->db->select( $table, @_);
}#----------

#-------------------------
sub find_Pg {
#-------------------------
my $self = shift;
my $table = shift;
$self->db->abstract = SQL::Abstract::Pg->new;
return $self->db->select( $table, @_);
}#----------

#-------------------------
sub find_direct_Pg {
#-------------------------
my($self, $title_alias, $limit_str, $offset) = @_;

$self->db->abstract = SQL::Abstract::Pg->new;
return $self->db->select( $title_alias, ['*'], undef, 
                          { 
                           order_by => { -asc => 'curr_date' },
                           limit => $limit_str, 
                           offset => $offset
                          } 
                        )->hashes;
}#----------

#-------------------------
sub find_reverse_Pg {
#-------------------------
my($self, $title_alias, $limit_str, $offset) = @_;

$self->db->abstract = SQL::Abstract::Pg->new;
return $self->db->select( $title_alias, 
                          ['*'], 
                          undef, 
                          { 
                           order_by => { -desc => 'curr_date' },
                           limit => $limit_str, offset => $offset
                          } 
                        )->hashes;
}#----------

#-------------------------
sub find_mysql {
#-------------------------
my $self = shift;
my $table = shift;
$self->db->abstract = SQL::Abstract::mysql->new;
return $self->db->select( $table, @_);
}#----------

#-------------------------
sub find_direct_mysql {
#-------------------------
my($self, $title_alias, $limit_str, $offset) = @_;

$self->db->abstract = SQL::Abstract::mysql->new;
return $self->db->select( $title_alias, ['*'], undef, 
                          {
                           order_by => { -asc => 'curr_date' },
                           limit => $limit_str, 
                           offset => $offset
                          } 
                        )->hashes;
}#----------

#-------------------------
sub find_reverse_mysql {
#-------------------------
my($self, $title_alias, $limit_str, $offset) = @_;

$self->db->abstract = SQL::Abstract::mysql->new;
return $self->db->select( $title_alias, ['*'], undef, 
                          { 
                           order_by => { -desc => 'curr_date' },
                           limit => $limit_str, offset => $offset
                          } 
                        )->hashes;
}#----------

#-------------------------
sub save {
#-------------------------
my $self = shift;
my $table = shift;
return $self->db->update( $table, @_);
}#----------

#-------------------------
sub create {
#-------------------------
my $self = shift;
my $table = shift;
my $last_id;

my $app = (split(/::/, $self))[0]->new;
my $db_driver = $app->db_driver;
my $action = 'create_'.$db_driver;

    # Use action relatively database driver
    $last_id = $app->db_select->$action( $self, $table, \@_ ),
    #$last_id = $self->db->last_insert_id('', '', $table, '')

return $last_id;
}#----------

#-------------------------
sub delete {
#-------------------------
my $self = shift;
my $table = shift;
$self->db->delete( $table, @_);
return;
}#----------

#-------------------------
sub correct_data_and_insert {
#-------------------------
my $self = shift;
my $c = shift;
my($message, $separator, $list_enable, $last_insert_id, $lastID, $order_for_time);

my $new_title_alias = $c->regexp->alias_clean_m( $c, trim($c->param('new_title_alias')) ); 

if( $new_title_alias eq 'invalid' ){ return $c->lang_config->{'ivalid_character'}->{$c->language}; }

my $templ = $c->param('template');

if(!($templ) || $templ eq 'gallery'){ # Змінити, коли буде можливість додавати шаблон 'gallery' !!!!!!!!!!!!!
    $templ = 'article';
}

$list_enable = $c->param('new_list_enable') || 'no';
if( $list_enable eq 'yes' ){
    $order_for_time = 'direct';
}

my $table_for_insert = 'level'.(substr($c->param( 'level' ), -1, 1) + 1);

my($table_live) = $c->db_table->like_table($c, $table_for_insert);
my($new_section_live) = $c->db_table->like_table($c, $new_title_alias);

if( !$table_live ){
  $c->db_table->create_table($c, $table_for_insert, 'level');
}
if( $new_section_live ne $new_title_alias ){
  $c->db_table->create_table($c, $new_title_alias, 'main');
}else{
  return '';
}
    
$separator = '/' if( $table_for_insert ne 'level1' && $table_for_insert ne 'level0' );
my $url_for_insert = $c->param('url').$separator.$new_title_alias; 

my %data_hash = (
                    'level'       => $table_for_insert,
                    'parent_dir'  => $c->param('title_alias'),
                    'title'       => $c->regexp->title_clean( trim( lc($c->param('new_title'))) ),
                    'title_alias' => $new_title_alias,
                    'url'         => $url_for_insert,
                    'template'    => $templ,
                    'description' => $c->param('description'),
                    'keywords'    => $c->param('keywords'),
                    'list_enable' => $list_enable,
                    'queue'       => "1",
                    'order_for_time' => $order_for_time,
                    'in_menu'     => 'no'
                );
                
    $last_insert_id = $self->create( $table_for_insert, \%data_hash );

    $lastID = $self->create( $new_title_alias, {
                    'level'     => $table_for_insert,
                    'level_id'  => $last_insert_id,
                    'rubric_id' => 0,
                    'curr_date' => $c->db_table->now($c),
                    'head'      => $c->lang_config->{'new_page_content'}->{$c->language},
                    'announce'  => encode('utf8', $c->lang_config->{'new_page_content'}->{$c->language}),
                    'content'   => $c->lang_config->{'new_page_content'}->{$c->language},
                    'template'  => $templ,
                    'comment_enable' => 'no',
                    'liked'     => 0,
                    'unliked'   => 0
                });

my $url_for_data = $c->routine->
url_for_search( 
    $url_for_insert, 
    $last_insert_id, 
    LiteralIdent->literal_for_url( $c, $c->lang_config->{'new_page_content'}->{$c->language} ),
    $list_enable
);
    $self->save( $new_title_alias, {'url' => $url_for_data}, {'id' => $lastID} );

return $message;
}#----------

#-------------------------
sub save_menu {
#-------------------------
use MyBlog::MenuForm;
my $self = shift;
my $c = shift;

my $menu_form = 
MyBlog::MenuForm->menu_tree( $c, 
                             $c->serve->select_struct( 
                             $c, 
                             [reverse sort @{$c->top_config->{'levels'}}] 
                             ) 
                           );
my($menu, $sitemap) = 
$c->routine_model->get_menu( $c, 
                             $c->serve->select_struct(
                             $c, 
                             [reverse sort @{$c->top_config->{'levels'}}]
                             ) 
                           );

return( $menu_form, $menu, $sitemap );
}#----------
1;