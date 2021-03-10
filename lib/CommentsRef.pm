package CommentsRef;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------
sub comments_ref_user {
#---------------------------
my($self, $c, $user_name) = @_;
my(%tab_name_page_id, @page_head, @comments, $page_head, $url);
my $table_users = $c->top_config->{'table'}->{'users'};
my $table_comments = $c->top_config->{'table'}->{'comments'};

my @tabl_names = $c->menu->find( $table_comments, 
                                 ['distinct(table_name)'], 
                                 {'nickname' => $user_name} )->flat;

foreach my $table_name(@tabl_names){
    $tab_name_page_id{$table_name} = $c->db_table->_page_id( $c, 
                                                             $user_name, 
                                                             $table_name);
}
my $prev_url;
foreach my $table_name(sort keys %tab_name_page_id){
    my @page_id = @{$tab_name_page_id{$table_name}};
    foreach(@page_id){
        $page_head = $c->menu->find( $table_name, ['head'], {'id' => $_} )->list;
        $url = $c->menu->find( $table_comments, ['url'], 
                               {
                                'page_id' => $_, 
                                'nickname' => $user_name, 
                                'table_name' => $table_name
                               } 
                             )->list;
        next if( $url eq $prev_url );

        $prev_url = $url;
        @comments = $c->menu->find( $table_comments, 
                                    ['id', 'curr_date', 'comment', 'press_indicat'], 
                                    {'page_id' => $_, 'nickname' => $user_name, 'url' => $url},
                                    {-desc => 'curr_date'} )->hashes;
    push @page_head, {'page_head' => $page_head, 'url' => $url, 'comments' => [@comments]};
    }

}
return \@page_head;
}#-----------
1;