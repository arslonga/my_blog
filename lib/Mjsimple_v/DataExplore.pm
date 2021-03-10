package DataExplore;
use Mojo::Base 'Mojolicious::Controller';

#-----------------------------------------
sub del_chapter {
#-----------------------------------------
my($self, $c, $title_alias, $level, $max_level) = @_;
my $table_comments = $c->top_config->{'table'}->{'comments'};
my $table_users = $c->top_config->{'table'}->{'users'};
my $search_table = $c->top_config->{'table'}->{'search_artcl'};
my(%edit_priority, @new_arr, @subs_tables, $res_edit_prior, 
   $title_als, $levels_string, $parent_dir, $result, $numb_items_in_level);

    my $next_level = 'level'.(substr($level, -1, 1) + 1);
    my $next_level_indicr = $c->db_table->like_table($c, $next_level);

#******************************
if($next_level_indicr){ # Якщо наявна таблиця нижчого рівня
#******************************
    $result = $c->menu->find( $next_level, ['title_alias'], {'parent_dir' => $title_alias} );
        while(my $table = $result->list){
            push @subs_tables, $table;
        }
        
        foreach my $curr_tabl(@subs_tables){
            $c->menu->delete($next_level, { title_alias => $curr_tabl });
            $c->db_table->drop_tbl( $c, $curr_tabl );
            
            # Remove the row with deleting table name from comments table
            eval{ $c->menu->delete($table_comments, {'table_name' => $curr_tabl}); };
            
            # Remove row relative to removing table from 'search' table
            eval{ $c->menu->delete($search_table, {'table_name' => $curr_tabl}); };
            
            # Get data about priority of editing from users table
            eval{ #==========================
            $res_edit_prior = $c->menu->find( $table_users, 
                                              ['id', 'edit_priority'], 
                                              { 'edit_priority' => {-like => [ $curr_tabl, "%".$curr_tabl, "%".$curr_tabl."%", $curr_tabl."%" ] } }
                                             );
            while(my($user_id, $edit_priority) = $res_edit_prior->list){
                $edit_priority{$user_id} = $edit_priority;
            }
    
            foreach my $key(sort keys %edit_priority){
                foreach( split(/\|/, $edit_priority{$key}) ){
                    push @new_arr, $_ if($_ ne $curr_tabl);
                }        
            $c->menu->save($table_users, {'edit_priority' => join('|', @new_arr)}, {'id' => $key});
            @new_arr = ();
            }
            }; # ===========================
        }
        $c->db_table->drop_tbl( $c, $title_alias );
        $c->menu->delete($level, { title_alias => $title_alias });
        $numb_items_in_level = $c->menu->find( $next_level, ['count(*)'] )->list;

} #****************
else{ #************
    my($table, $parent_dir) = $c->menu->find( $level, ['title_alias', 'parent_dir'], { title_alias => $title_alias } )->list;

    $c->db_table->drop_tbl( $c, $table );
    $c->menu->delete($level, { title_alias => "$title_alias" });
    
    # Remove the row with deleting table name from comments table
    eval{ $c->menu->delete($table_comments, {'table_name' => $table}); };
    
    # Remove row relative to removing table from 'search' table
    eval{ $c->menu->delete($search_table, {'table_name' => $table}); };
    
    # Get data about priority of editing from users table
    eval{ #==========================
    $res_edit_prior = $c->menu->find( $table_users, 
                                      ['id', 'edit_priority'],  
                                      { 'edit_priority' => {-like => [ $table, "%".$table, "%".$table."%", $table."%" ] } }
                                      );
    while(my($user_id, $edit_priority) = $res_edit_prior->list){
        $edit_priority{$user_id} = $edit_priority;
    }
    
    foreach my $key(sort keys %edit_priority){
        foreach( split(/\|/, $edit_priority{$key}) ){
            push @new_arr, $_ if($_ ne $table);
        }        
        $c->menu->save($table_users, {'edit_priority' => join('|', @new_arr)}, {'id' => $key});
        @new_arr = ();
    }
    }; # ===========================
    
    my $numb_items_for_parent_dir = $c->menu->find( $level, ['count(parent_dir)'], {'parent_dir' => $parent_dir} )->list;

    if(!$numb_items_for_parent_dir){
        
        # Remove the table what is parent for removed section (if it is not 'main')
        $c->db_table->drop_tbl( $c, $parent_dir) if(!$numb_items_for_parent_dir && $parent_dir ne 'main');
        my $prev_level = 'level'.(substr($level, -1, 1) - 1);
        if( $prev_level ne 'level0' ){
            $c->menu->delete( $prev_level, { title_alias => $parent_dir } );
        }
    }
    
    $numb_items_in_level = $c->menu->find( $level, ['count(*)'] )->list;

}#*****************

}#----------------
1;