package MyBlog::RssArticles;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(encode decode);
use Mojo::Date;

#---------------------------
sub rss_articles {
#---------------------------
my($self, $c) = @_;
my $language = $c->language;
my $table_rss_setting = $c->top_config->{'table'}->{'rss_setting'};
my $table_access = $c->top_config->{'adm'}->{'table'}->{'access'}->{'name'};
my $table_rubric = $c->top_config->{'table'}->{'rubric'};
my $action = 'encode_'.$c->db_driver;
my(%date_Data_hash, @res_has, $title, $description, $list_number, $without_rubr_res, $result);

($title, $description, $list_number) = $c->menu->find( $table_rss_setting, 
                                                       [
                                                        'title', 
                                                        'description', 
                                                        'list_number'
                                                       ] 
                                                     )->list;
$list_number = 0 if(!$list_number);

############# Create RSS data for posts #####################################
my @title_alias = @{TitleAliasList->title_alias_list( $c )};
    
foreach my $curr_table(@title_alias){
    $without_rubr_res = $c->db->query(qq[ SELECT * FROM $curr_table 
                                          WHERE rubric_id = 0 
                                          ORDER BY curr_date DESC 
                                          LIMIT $list_number ])->hashes;
    foreach my $data_rss(@$without_rubr_res){
        $data_rss->{'rubric'} = $c->lang_config->{'no_rubric'}->{$language};
        #$data_rss->{'url'} = "" if($data_rss->{'url'} eq '/');
        next if( $data_rss->{'head'} eq $c->lang_config->{'new_page_content'}->{$language} );
        $date_Data_hash{$data_rss->{'curr_date'}} = $data_rss;
    } 

    $result = $c->db->query(qq[ SELECT $curr_table.curr_date, $curr_table.level, 
                                $curr_table.id, $curr_table.rubric_id, 
                                $curr_table.head, $curr_table.announce, 
                                $curr_table.url, $curr_table.description, 
                                $table_rubric.rubric FROM $curr_table, $table_rubric
                                WHERE $curr_table.rubric_id = $table_rubric.id 
                                ORDER BY curr_date DESC 
                                LIMIT $list_number ])->hashes;
                                        
    foreach my $data_rss(@$result){
        $data_rss->{'rubric'} = uc $data_rss->{'rubric'} if $data_rss->{'rubric'};
        $data_rss->{'url'} = "" if($data_rss->{'url'} eq '/');
        next if( $data_rss->{'head'} eq 
        $c->lang_config->{'new_page_content'}->{$language} ); # || $data_rss->{'head'} ~~ undef );
        $date_Data_hash{$data_rss->{'curr_date'}} = $data_rss;
    }
}

my $posts_string = $c->render_to_string(
template => 'rss/rss_post_template',
title => $title,
link        => $c->protocol.'://'.$c->req->headers->host,
language    => $language,
description => $description,
lastBuildDate => Mojo::Date->new($c->db_table->now($c)),
webMaster     => $c->menu->find($table_access, 'email')->list,
list_number => $list_number,
date_Data_hash => \%date_Data_hash
);

$c->spurt( $c->$action( $posts_string ), $c->top_config->{'rss_articles_path'} );
}#-------------

#---------------------------
sub rss_comments {
#---------------------------
my($self, $c) = @_;
my $language = $c->language;
my $table_rss_setting = $c->top_config->{'table'}->{'rss_setting'};
my $table_access = $c->top_config->{'adm'}->{'table'}->{'access'}->{'name'};
my $table_comments = $c->top_config->{'table'}->{'comments'};
my $action = 'encode_'.$c->db_driver;
my(%date_Data_hash);

my($title, $description, $list_number) = 
$c->menu->find( $table_rss_setting, ['title', 'description', 'list_number'] )->list;
$list_number = 0 if(!$list_number);

############# Create RSS data for comments #####################################
my $result = $c->db->query(qq[ SELECT id, curr_date, page_id, table_name, url, comment
                               FROM $table_comments
                               WHERE press_indicat = 'yes' 
                               ORDER BY curr_date DESC 
                               LIMIT $list_number ]);

while(my $data_rss = $result->hash){
    $data_rss->{'url'} = $data_rss->{'url'}.'#'.$c->top_config->{'comment_prefix'}.$data_rss->{'id'};
    #$data_rss->{'comment'} = (split(/\./, $data_rss->{'comment'}))[0];
    $data_rss->{'head'} = $c->menu->find( $data_rss->{'table_name'}, 
                                          ['head'], 
                                          {'id' => $data_rss->{'page_id'}}
                                        )->list;
    $date_Data_hash{$data_rss->{'curr_date'}} = $data_rss;
}

my $comments_string = $c->render_to_string(
template => 'rss/rss_comments_template',
title => $title,
link        => $c->protocol.'://'.$c->req->headers->host,
language    => $language,
description => $description,
lastBuildDate => Mojo::Date->new($c->db_table->now($c)),
webMaster     => $c->menu->find($table_access, 'email')->list,
list_number => $list_number,
date_Data_hash => \%date_Data_hash
);

#$c->spurt( $comments_string, $c->top_config->{'rss_comments_path'} );
#$c->spurt( $c->$action( $comments_string ), $c->top_config->{'rss_comments_path'} );
$c->spurt( encode( 'utf8', $comments_string ), $c->top_config->{'rss_comments_path'} );
}#-------------
1;