package DB::Select;
use Mojo::Base -base;
use base 'DB';
use Mojo::Collection qw(c);

#----------------------------------------------
sub now_time{
#----------------------------------------------
my($self, $c) = @_;
return (split(/\./, $c->db->query(qq[SELECT NOW()])->list))[0];
}#---------------

#----------------------------------------------
sub level_id{
#----------------------------------------------
my($self, $c, $table, $arg) = @_;
my($id) = $c->db->select($table, {title_alias => $arg})->list;
return $id;
}#---------------

#----------------------------------------------
sub count_rows{
#----------------------------------------------
my($self, $c, $table) = @_;
return $c->db->select($table, ['count(*)'])->list;
}#---------------

#----------------------------------------------
sub page_media_data{
#----------------------------------------------
my($self, $c, $id, $table) = @_;
my @data_arr;
my $i = 0;
foreach my $item( @{$c->top_config->{'tables_of_upload'}} ){    
    $data_arr[$i] = $c->db->select( $item, ['*'], 
                                    {page_id => $id, title_alias => $table}
                                  )->hashes;
$i++;    
}
return [@data_arr];
}#---------------

#----------------------------------------------
sub drop_table{
#----------------------------------------------
my($self, $c, $table) = @_;
eval{ $c->db->query(qq[ DROP TABLE $table ]); };
return;
}#---------------

#============================ Pg ===============================================

#-------------------------
sub like_table_Pg {
#-------------------------
my($self, $c, $table) = @_;
$c->db->abstract = SQL::Abstract->new;
return $c->db->select( 'pg_catalog.pg_tables', 
                       ['tablename'], 
                       {tablename => {-like => $table}}
                     )->list;
}#-------

#-------------------------
sub like_table_obj_Pg {
#-------------------------
my($self, $c, $table) = @_;
$c->db->abstract = SQL::Abstract->new;
return $c->db->select( 'pg_catalog.pg_tables', 
                       ['tablename'], 
                       {tablename => {-like => $table."%"}}
                     );
}#-------

#-------------------------
sub arr_like_table_Pg {
#-------------------------
my($self, $c, $table) = @_;
$c->db->abstract = SQL::Abstract->new;
return $c->db->select( 'pg_catalog.pg_tables', 
                       ['tablename'], 
                       {tablename => {-like => $table."%"}}
                     )->arrays;
}#-------

#-------------------------
sub create_Pg {
#-------------------------
my($self, $c, $table, $args) = @_;
$c->db->abstract = SQL::Abstract::Pg->new;
return $c->db->insert( $table, @$args, {returning => 'id'})->hash->{id};
}#-------

#-------------------------
sub prev_page_Pg {
#-------------------------
my($self, $c, $table, $id, $curr_date) = @_;
$c->db->abstract = SQL::Abstract::Pg->new;
return $c->db->select( $table, 
                       #['id', 'head', 'url'], 
                       ['curr_date', 'head', 'url'],
                       { 
                        #id => $c->db->select( $table, 
                        #                      'MAX(id)', 
                        #                      {id => {'<', $id}}, 
                         'curr_date' => $c->db->select( $table, 
                                              'MAX(curr_date::text)', 
                                              {curr_date => {'<', $curr_date}}, 
                                              {limit => 1} 
                                            )->list 
                       } 
                     )->list;
}#---------

#-------------------------
sub next_page_Pg {
#-------------------------
my($self, $c, $table, $id, $curr_date) = @_;
$c->db->abstract = SQL::Abstract::Pg->new;
return $c->db->select( $table, 
                       #['id', 'head', 'url'],
                       ['curr_date', 'head', 'url'], 
                       { 
                        #id => $c->db->select( $table, 
                        #                      'MIN(id)', 
                        #                      {id => {'>', $id}},
                        'curr_date' => $c->db->select( $table, 
                                              'MIN(curr_date::text)', 
                                              {'curr_date' => {'>', $curr_date}},
                                              {limit => 1} 
                                            )->list 
                       } 
                     )->list;
}#---------

#-------------------------
sub id_comment_in_rss_Pg {
#-------------------------
my($self, $c, $id) = @_;
my $table_rss_setting = $c->top_config->{'table'}->{'rss_setting'};
my $table_comments = $c->top_config->{'table'}->{'comments'};

my $limit_rss = $c->db->select( $table_rss_setting, ['list_number'] )->list;
$c->db->abstract = SQL::Abstract::Pg->new;
return $c->db->select( $table_comments, 
                       ['id'], 
                       {id => $id}, 
                       {order_by => {-desc => 'id'}, limit => $limit_rss} 
                     )->list;
}#---------

#----------------------------------------------
sub distinct_date_Pg {
#----------------------------------------------
my $self = shift;
my($c, $table) = @_; 
return $c->db->select( $table, ['distinct((date(curr_date)))'] );
}#---------------

#----------------------------------------------
sub select_date_Pg {
#----------------------------------------------
my $self = shift;
my($c, $table, $year, $month) = @_;
return $c->db->select( $table, 
                       ['curr_date'], 
                       {'curr_date::text' => {-like => $year.'-'.$month."-%"}} 
                     );		 
}#---------------

#----------------------------------------------
sub arch_link_content_Pg{
#----------------------------------------------
my $self = shift;
my($c, $table, $year_month_url) = @_;
return $c->db->select( $table, 
                       ['*'], 
                       {'curr_date::text' => {like => "$year_month_url%"}} 
                     );
}#---------------

#----------------------------------------------
sub year_month_Pg {
#----------------------------------------------
my $self = shift;
my($c, $table, $year, $year_month_url) = @_;
return $c->db->select( $table, 
                       ['distinct(curr_date::text)'], 
                       {
                        'curr_date::text' => {-like => $year."%", 
                                              -not_like => $year_month_url."%"}
                       } 
                       );		
}#---------------

#----------------------------------------------
sub categories_Pg {
#----------------------------------------------
my $self = shift;
my($c, $table) = @_;
return $c->menu->find( $table, ['distinct on(id) rubric'], {}, 'id' )->flat;		
}#---------------

#============================ MySQL ============================================

#-------------------------
sub like_table_mysql {
#-------------------------
 my($self, $c, $table) = @_;
return $c->db->query(qq[SHOW TABLES LIKE "$table"])->list;	
}#-------

#-------------------------
sub like_table_obj_mysql {
#-------------------------
 my($self, $c, $table) = @_;
return $c->db->query(qq[SHOW TABLES LIKE "$table%"]);	
}#-------

#-------------------------
sub arr_like_table_mysql {
#-------------------------
 my($self, $c, $table) = @_;
return $c->db->query(qq[SHOW TABLES LIKE "$table"])->arrays;	
}#-------

sub create_mysql {
#-------------------------
my($self, $c, $table, $args) = @_;
$c->db->abstract = SQL::Abstract->new;
$c->db->insert( $table, @$args );
return $c->db->last_insert_id('', '', $table, '')
}#-------

#-------------------------
sub prev_page_mysql {
#-------------------------
my($self, $c, $table, $id, $curr_date) = @_;
$c->db->abstract = SQL::Abstract::mysql->new;
return $c->db->select( $table, 
                       #['id', 'head', 'url'],
                       ['curr_date', 'head', 'url'], 
                       { 
                        #id => $c->db->select( $table, 
                        #                      'MAX(id)', 
                        #                      {id => {'<', $id}}, {limit => 1} 
                        #                    )->list 
                        'curr_date' => $c->db->select( $table, 
                                              'MAX(curr_date)', 
                                              {curr_date => {'<', $curr_date}}, {limit => 1} 
                                            )->list 
                       } 
                     )->list;
}#---------

#-------------------------
sub next_page_mysql {
#-------------------------
my($self, $c, $table, $id, $curr_date) = @_;
$c->db->abstract = SQL::Abstract::mysql->new;
return $c->db->select( $table, 
                       #['id', 'head', 'url'], 
                       ['id', 'head', 'url'],
                       { 
                        #id => $c->db->select( $table, 
                        #                      'MIN(id)', 
                        #                      {id => {'>', $id}}, 
                        #                      {limit => 1} 
                        #                    )->list 
                        'curr_date' => $c->db->select( $table, 
                                              'MIN(curr_date)', 
                                              {curr_date => {'>', $curr_date}}, 
                                              {limit => 1} 
                                            )->list
                       } 
                     )->list;
}#---------

#-------------------------
sub id_comment_in_rss_mysql {
#-------------------------
my($self, $c, $id) = @_;
my $table_rss_setting = $c->top_config->{'table'}->{'rss_setting'};
my $table_comments = $c->top_config->{'table'}->{'comments'};

my $limit_rss = $c->db->select( $table_rss_setting, ['list_number'] )->list;
$c->db->abstract = SQL::Abstract::mysql->new;
return $c->db->select( $table_comments, 
                       ['id'], 
                       {id => $id}, 
                       {order_by => {-desc => 'id'}, limit => $limit_rss} 
                     )->list;
}#---------

#----------------------------------------------
sub distinct_date_mysql {
#----------------------------------------------
my $self = shift;
my($c, $table) = @_; 
return $c->db->select( $table, ['distinct(left(curr_date, 7))'] );
}#---------------

#----------------------------------------------
sub select_date_mysql {
#----------------------------------------------
my $self = shift;
my($c, $table, $year, $month) = @_;
return $c->db->select( $table, 
                       ['(left(curr_date, 7))'], 
                       {curr_date => {-like => $year.'-'.$month."-%"}} 
                     );		 
}#---------------

#----------------------------------------------
sub arch_link_content_mysql{
#----------------------------------------------
my $self = shift;
my($c, $table, $year_month_url) = @_;
return $c->db->select( $table, 
                       ['*'], 
                       {'curr_date' => {like => "$year_month_url%"}} 
                     );
}#---------------

#----------------------------------------------
sub year_month_mysql {
#----------------------------------------------
my $self = shift;
my($c, $table, $year, $year_month_url) = @_;
return $c->db->select( $table, 
                       ['(left(curr_date, 7))'], 
                       {curr_date => {-like => $year."%", 
                                      -not_like => $year_month_url."%"}} 
                     );		
}#---------------

#----------------------------------------------
sub categories_mysql {
#----------------------------------------------
my $self = shift;
my($c, $table) = @_;
#return $c->menu->find( $table, ['distinct(rubric)'], {}, 'id' )->flat;
return $c->menu->find( $table, ['distinct(rubric)'] )->flat;		
}#---------------
1;