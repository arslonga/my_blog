package DB::Delete;
use base 'DB';
use Mojo::Base 'Mojolicious::Controller';

#----------------------------------------------
sub new{
#----------------------------------------------
   my $proto = shift;
   my $class = ref($proto) || $proto;

   my $self = {};

   bless($self, $class);
return $self;
}#-------------

#----------------------------------------------
sub delete_article{
#----------------------------------------------
my($self, $c, $list_enable, $title_alias, $id, $level) = @_;
my $table_users    = $c->top_config->{'table'}->{'users'};
my $table_comments = $c->top_config->{'table'}->{'comments'};
my $search_table   = $c->top_config->{'table'}->{'search_artcl'};

$self = {
         'no' => sub{
                     eval{ $c->db->query( qq[ DROP TABLE $title_alias ]); };
                     $c->menu->delete( $level, 
                                       {'title_alias' => $title_alias}
                                     );
                     eval{ $c->menu->delete( $table_comments, 
                                             {'table_name' => $title_alias} 
                                           ); 
                     };
                     # Remove row related to current table from 'search' table
                     eval{
                        $c->menu->delete( $search_table, 
                                          {'table_name' => $title_alias}
                                        );
                     };
                    
                     my $count_in_level = $c->menu->find($level, ['count(*)'])->list;
                     if(!$count_in_level){
                        $c->db->query(qq[ DROP TABLE $level ]);                        
                     }
                     return 1;
                    },
                    
        'yes' => sub{
                     my(%edit_priority, @new_arr, $res_edit_prior);
                     $c->menu->delete($title_alias, {'id' => $id});
                     eval{ $c->menu->delete( $table_comments, 
                                             {
                                              'page_id' => $id, 
                                              'table_name' => $title_alias
                                             }
                                           ); 
                     };
                     # Remove row related to current table from 'search' table
                     eval{ $c->menu->delete( $search_table, 
                                             {
                                              'page_id' => $id, 
                                              'table_name' => $title_alias
                                             }
                                           ); 
                     };
                     my $count_in_table = $c->menu->find( $title_alias, 
                                                          ['count(*)']
                                                        )->list;
                     
                     if(!$count_in_table){
                        $c->db->query(qq[ DROP TABLE $title_alias ]);
                        $c->menu->delete($level, {'title_alias' => $title_alias});
                     
                     # Get data on editing priorities from the user table 
                    eval{ #==========================
                    $res_edit_prior = 
                    $c->menu->find( $table_users, 
                                    ['id', 'edit_priority'], 
                                    {'edit_priority' => {-regexp => $title_alias}}
                                  );
                        while( my( $user_id, $edit_priority ) = 
                        $res_edit_prior->list ){
                            $edit_priority{$user_id} = $edit_priority;
                        }
    
                    foreach my $key(sort keys %edit_priority){
                        foreach( split(/\|/, $edit_priority{$key}) ){
                            push @new_arr, $_ if($_ ne $title_alias);
                        }        
                    $c->menu->save( $table_users, 
                                    {'edit_priority' => join('|', @new_arr)}, 
                                    {'id' => $key}
                                  );
                    @new_arr = ();
                    }
                    }; # ===========================
                    
                    my $count_in_level = $c->menu->find($level, ['count(*)'])->list;
                        if(!$count_in_level){
                            $c->db->query(qq[ DROP TABLE $level ]);                        
                        }
                    
                    }
                     return $count_in_table;
                    }
        };

return $self->{$list_enable}->();
}#---------------
1;