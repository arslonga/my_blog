package DB::Table;
use Mojo::Base -base;
use base 'DB';
use Mojo::Collection qw(c);

has 'db';

#-------------------------
sub now {
#-------------------------
my($self, $c) = @_;
return $c->db_select->now_time($c);
}#---------

#----------------------------------------------
sub count_rws{
#----------------------------------------------
my($self, $c, $table) = @_;
return $c->db_select->count_rows($c, $table);
}#---------------

#----------------------------------------------
sub drop_tbl{
#----------------------------------------------
my($self, $c, $table) = @_;
return $c->db_select->drop_table($c, $table);
}#---------------

#-------------------------
sub like_table {
#-------------------------
my($self, $c, $table) = @_;
my $action_like = 'like_table_'.$c->db_driver;
return $c->db_select->$action_like($c, $table);
}#---------

#-------------------------
sub like_table_obj {
#-------------------------
my($self, $c, $table) = @_;
my $action_like = 'like_table_obj_'.$c->db_driver;
return $c->db_select->$action_like($c, $table);
}#---------

#-------------------------
sub like_table_arr {
#-------------------------
my($self, $c, $table) = @_;
my $action_like = 'arr_like_table_'.$c->db_driver;
return $c->db_select->$action_like($c, $table);
}#---------

#-------------------------
sub media_data {
#-------------------------
my($self, $c, $id, $table) = @_;
return $c->db_select->page_media_data($c, $id, $table);
}#---------

#-------------------------
sub comment_parent_id{
#-------------------------
my($self, $c, $table, $url, $page_id) = @_;

return $c->db->select( $table, 
                       ['parent_id'], 
                       {url => $url, page_id => $page_id}, 
                       {-desc => 'curr_date'}
                     );
}#---------

#-------------------------
sub prev_pag {
#-------------------------
my($self, $c, $table, $id, $curr_date) = @_;
my $action = 'prev_page_'.$c->db_driver;
return $c->db_select->$action($self, $table, $id, $curr_date);
}#---------

#-------------------------
sub next_pag {
#-------------------------
my($self, $c, $table, $id, $curr_date) = @_;
my $action = 'next_page_'.$c->db_driver;
return $c->db_select->$action($self, $table, $id, $curr_date);
}#---------

#-------------------------
sub _page_id {
#-------------------------
my($self, $c, $user_name, $table_name) = @_;

my $table_comments = $c->top_config->{'table'}->{'comments'};

return c( $c->menu->find( $table_comments, 
                          ['page_id'],
                          {
                           'nickname' => $user_name,
                           'table_name' => $table_name
                          }, {-desc => 'curr_date'} )
                          ->flat )
                          ->uniq->to_array;
}#---------

#----------------------------------------------
sub id_comment_in_limit_rss {
#----------------------------------------------
my($self, $c, $id) = @_;
my $action = 'id_comment_in_rss_'.$c->db_driver;
return $c->db_select->$action($c, $id);
}#---------------

#----------------------------------------------
sub dstnct_date {
#----------------------------------------------
my($self, $c, $table) = @_;
my $action = 'distinct_date_'.$c->db_driver;
return $c->db_select->$action($c, $table);
}#---------------

#----------------------------------------------
sub get_date {
#----------------------------------------------
my($self, $c, $table, $year, $month) = @_;
my $action = 'select_date_'.$c->db_driver;
return $c->db_select->$action($c, $table, $year, $month);
}#---------------

#----------------------------------------------
sub arch_link_content {
#----------------------------------------------
my($self, $c, $table, $year_month_url) = @_;
my $action = 'arch_link_content_'.$c->db_driver;
return $c->db_select->$action($c, $table, $year_month_url);
}#---------------

#----------------------------------------------
sub yr_month {
#----------------------------------------------
my($self, $c, $table, $year, $year_month_url) = @_;
my $action = 'year_month_'.$c->db_driver;
return $c->db_select->$action($c, $table, $year, $year_month_url);
}#---------------

#----------------------------------------------
sub rubrics {
#----------------------------------------------
my($self, $c, $table) = @_;
my $action = 'categories_'.$c->db_driver;
return $c->db_select->$action($c, $table);
}#---------------

# CREATING ##########################################
#-------------------------
sub create_struct {
#-------------------------
my($self, $c, $key, $table) = @_;
my $action = 'create_db_structure_'.$c->db_driver;
return $c->db_create->$action($c, $key, $table);
}#---------

#-------------------------
sub create_table {
#-------------------------
my($self, $c, $table, $key) = @_;
my $action = 'create_table'.$c->db_driver;
return $c->db_create->$action($c, $table, $key);
}#---------
1;