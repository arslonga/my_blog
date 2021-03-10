package MyBlog::CommentsTree;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(encode decode dumper steady_time);
use Mojo::Collection qw(c);
use Mojo::JSON qw(decode_json);

#-----------------------------------------------
sub comments_tree {
#-----------------------------------------------
my($self, $c, $page_id) = @_;
my($comments, $next_level, $client_id, $last_insert_id, $date_now);
eval{ $client_id = $c->session('client')->[0]; };
my $client_check = $c->sess_check->client( $c, $client_id );

my $language        = $c->language;
my $table_comments  = $c->top_config->{'table'}->{'comments'};
my $table_users     = $c->top_config->{'table'}->{'users'};
my $max_level       = $c->slurp( $c->top_config->{'comments_levels_deep_file'} ); ################################
my $img_path        = $c->top_config->{'img_path'};
my $button_val      = $c->lang_config->{'buttons'}->{$language}->{'send'};
my $response_from_label = $c->lang_config->{'labels'}->{$language}->{'response_from'}.
' <b class="nickname">'.$c->session('client')->[1].'</b>:' if( $client_check );

my $comment_inappropriate = '<i class="comment_hidden"></i>';
my $reply_frase     = lc $c->lang_config->{'reply'}->{$language};
my $change_frase    = lc $c->lang_config->{'change'}->{$language};
my $comment_prefix  = $c->top_config->{'comment_prefix'};
my $admin_check     = $c->sess_check->admin( $c );
my $json_config_path = $c->top_config->{'in_js_conf_path'};
$last_insert_id     = $c->cookie('added_comment') || "";
$date_now = Mojo::Date->new( $c->db_table->now($c) )->epoch;

my $pClass = decode_json( $c->slurp( $json_config_path ) )->{commentPclass};

my $edit_link_admin = "";
my $url = $c->req->url;
$url =~ s/\?.*$//;
eval{ $client_id = $c->session('client')->[0]; };
$client_id = "" if(!$client_id);

####################################################################
my(%hash_id_subs, %hash_id_subs_mod);
my %node_hash;
my %exist;
my @parent_id = ();

#my $t0 = steady_time();
                          
my @hashref_arr = $c->menu->find( $table_comments, 
                                  ['*'], 
                                  {'url' => "$url"}, 
                                  {-desc => 'id'})->hashes;

foreach(@hashref_arr){
    $_->{'comment'} = $comment_inappropriate if($_->{'press_indicat'} eq 'no');
}

#my $result = $c->db_table->comment_parent_id( $c, $table_comments, $url, $page_id );
my @res_array = $c->db_table->comment_parent_id( $c, $table_comments, $url, $page_id )->flat;
my $collection = c(@res_array);
                               
    #while(my($parent_id) = $result->list){
    foreach my $parent_id( @{$collection->uniq->to_array} ){ 
        push @parent_id, $parent_id;
        $exist{$parent_id} = 1;
    }

foreach(@hashref_arr){
    $hash_id_subs{$_->{id}} = $_;
    #if($exist{$_->{parent_id}}){
        if( $_->{parent_id} != 0 ){        
            my($parent_nickname) = $c->menu->find($table_comments, ['nickname'], 
                                    {url     => $url,
                                     page_id => $page_id,
                                     id      => $_->{parent_id}
                                    }, 
                                    {-desc => 'curr_date'})->list;
            $_->{parent_nickname} = $parent_nickname;
        }
        my $result = $c->menu->find( $table_comments, 
                                     ['id'], 
                                     {url => $url, parent_id => [-and => {'=', $_->{parent_id}}, {'!=', 0}]
                                                     #}, {-desc => 'curr_date'}
                                     }, {-asc => 'curr_date'}
                                   );
                                   
        my @id_arr = ();
        while(my($id) = $result->list){
            push @id_arr, $id;
        }
        $node_hash{$_->{parent_id}} = [@id_arr];
    #}
}

foreach( @hashref_arr ){
    my @subs_arr = ();
    if($node_hash{$_->{id}}){
        $hash_id_subs_mod{$_->{id}} = $_;
        #say $_->{id}, " \= ", @{$node_hash{$_->{id}}};
        foreach my $item(@{$node_hash{$_->{id}}}){
            #print "\$item \= $item\n";
            push @subs_arr, __PACKAGE__->select_next_sub($c, $item, $_->{level}, [@subs_arr], \%hash_id_subs);
            delete $hash_id_subs{$item};
            #print "\@subs_arr \= ", Dumper(@subs_arr), "\n";
            $hash_id_subs_mod{$_->{id}}->{subs} = [@subs_arr];
        }
    }
}

#say "ELAPSED \= ", steady_time() - $t0;
####################################################################
$comments.="<hr>\n";

my $i = 0;
foreach( reverse sort {$a <=> $b} keys %hash_id_subs ){
my($edit_link_comment_client, $comment_date, $user_id, $id_coomment_accord, 
   $more_button_div_id, $date_diff);
my $style_comment = ' class="'.$pClass.'"';
my $status = "";

    if($c->menu->find( $table_users, 
                       ['view_status'], 
                       {'login' => $hash_id_subs{$_}->{'nickname'}})->list eq 'no'){
        next;
    }
    $user_id = $c->menu->find( $table_users, 
                               ['id'], 
                               {'login' => $hash_id_subs{$_}->{'nickname'}})->list;
    
    if( $last_insert_id eq $hash_id_subs{$_}->{'id'} ){
        $style_comment = substr( $style_comment, 0, length($style_comment)-1 ).' recent_comment"';
    }
    
    if( $admin_check ){
        $edit_link_admin = ' <span class="separator">|</span> <a class="arch_link" href="/user.comment?id='.$hash_id_subs{$_}->{'id'}.'&user_id='."$user_id\"> ".$c->lang_config->{'edit'}->{$c->language}."</a>\n";
    }
    
    $comment_date = $hash_id_subs{$_}->{'curr_date'};
    $date_diff = $date_now - Mojo::Date->new( $comment_date )->epoch;
    $comment_date = $c->date_format($date_diff, $comment_date);    
    $id_coomment_accord = $hash_id_subs{$_}->{'id'}.'_comment';
    $more_button_div_id = 'moreDiv'.$comment_prefix.$hash_id_subs{$_}->{'id'};
    
my $like_id = 'like_'.$hash_id_subs{$_}->{'id'};
my $unlike_id = 'unlike_'.$hash_id_subs{$_}->{'id'};
my $like_btn_name = 'like'.$hash_id_subs{$_}->{'id'};
my $unlike_btn_name = 'unlike'.$hash_id_subs{$_}->{'id'};
my $liked_cnt = $hash_id_subs{$_}->{'liked'} || 0;
my $unliked_cnt = $hash_id_subs{$_}->{'unliked'} || 0;

if( !$client_check ){
    $status = ' disabled';
}elsif(defined $c->signed_cookie('user'.$client_id.'_'.$hash_id_subs{$_}->{'id'}) && 
    $hash_id_subs{$_}->{'id'} == $c->signed_cookie('user'.$client_id.'_'.$hash_id_subs{$_}->{'id'})){
    $status = ' disabled';
}

my $like_unlike_block = $c->like_unlike_block( $like_btn_name,
                                               $unlike_btn_name,
                                               $hash_id_subs{$_}->{'id'},
                                               $like_id, 
                                               $unlike_id,
                                               $client_id, 
                                               $status, 
                                               $liked_cnt, 
                                               $unliked_cnt
                                             );

my $disabled_like_unlike_block = $like_unlike_block;
if( $client_check ){
    $disabled_like_unlike_block = '';
}
my $user_comment_list_href = '/view.user?id='.$user_id;
if( $hash_id_subs{$_}->{'press_indicat'} eq 'no' ){

$comments.=<<COMM;
<div class="comment_block" id="$comment_prefix$hash_id_subs{$_}->{'id'}" name="$comment_prefix$hash_id_subs{$_}->{'id'}">
<p$style_comment>
$hash_id_subs{$_}->{'comment'}
</p>
COMM
    
}else{
$hash_id_subs{$_}->{'comment'} = decode('utf8', $hash_id_subs{$_}->{'comment'}) || $hash_id_subs{$_}->{'comment'};
$comments.=<<COMM;
<div class="comment_block" id="$comment_prefix$hash_id_subs{$_}->{'id'}" name="$comment_prefix$hash_id_subs{$_}->{'id'}">
<!--Link to the page of given user comments-->
<a href="$user_comment_list_href"><span class="nickname">$hash_id_subs{$_}->{'nickname'}</span></a>
<span class="date_comment">$comment_date</span>
$edit_link_admin    
<p$style_comment>
$hash_id_subs{$_}->{'comment'}
</p>
$disabled_like_unlike_block
COMM

}

if( $client_check ){
    if( $hash_id_subs{$_}->{'level'} < $max_level ){
        $next_level = $hash_id_subs{$_}->{'level'} + 1;
    }else{
        $next_level = $hash_id_subs{$_}->{'level'};
    }

#*****************************
if( $user_id == $client_id && ($hash_id_subs{$_}->{'comment'} ne $c->lang_config->{'comment_deleted'}->{$c->language}) 
    && !($hash_id_subs{$_}->{'comment'} =~ /$comment_inappropriate/) ){
#*****************************
$hash_id_subs{$_}->{'comment'} = decode('utf8', $hash_id_subs{$_}->{'comment'}) || $hash_id_subs{$_}->{'comment'};
my $id_edit_coomment_accord = $hash_id_subs{$_}->{'id'}.'_edit';

$edit_link_comment_client = $c->edit_link_comment_client($id_edit_coomment_accord,
                                                         $change_frase,
                                                         $url,
                                                         $comment_prefix,
                                                         $hash_id_subs{$_}->{'id'},
                                                         $page_id,
                                                         $next_level,
                                                         $response_from_label,
                                                         $hash_id_subs{$_}->{'comment'},
                                                         $button_val
                                                        );

}#**************
else{
  $edit_link_comment_client = "";
} 

#$edit_link_comment_client = ""; # Disable user`s comment editing for users 

if( $hash_id_subs{$_}->{'comment'} ne $c->lang_config->{'comment_deleted'}->{$language} 
    && !($hash_id_subs{$_}->{'comment'} =~ /$comment_inappropriate/) ){
    
$comments .= $c->comment_bottom($id_coomment_accord,
                                $reply_frase,
                                $like_unlike_block,
                                $edit_link_comment_client,
                                $url,
                                $comment_prefix,
                                $hash_id_subs{$_}->{'id'},
                                $page_id,
                                $next_level,
                                $response_from_label,
                                $button_val
                               );

}

}
$comments.="<hr>\n</div>\n<div id=\"$more_button_div_id\"></div>\n";

    if($hash_id_subs{$_}->{subs}){
    
    my $subcomments =__PACKAGE__->select_including( $c, $hash_id_subs{$_}->{subs}, $table_users, $page_id, $last_insert_id, $pClass );
        $comments.=$subcomments;        
    }
$status = '';
} # foreach ------
#say "ELAPSED2 \= ", steady_time() - $t0;
return $comments;
}#--------------

#------------------------------------------
sub select_next_sub{
#------------------------------------------
my($self, $c, $id, $level, $ref_subs_arr, $ref_hash_id_subs) = @_;
my %hash_id_subs = %{$ref_hash_id_subs};

return $hash_id_subs{$id};
}#-------------

#----------------------------------------
sub select_including{
#----------------------------------------
my($self, $c, $ref_subs_content, $table_users, $page_id, $last_insert_id, $pClass) = @_;
my($comments, $next_level, $client_id);
eval{ $client_id = $c->session('client')->[0]; };
my $client_check = $c->sess_check->client( $c, $client_id );

my $language = $c->language;
my $table_comments = $c->top_config->{'table'}->{'comments'};
my $max_level = $c->slurp( $c->top_config->{'comments_levels_deep_file'} ); ################################
my $img_path = $c->top_config->{'img_path'};
my @subs_content = @$ref_subs_content;
my $button_val = $c->lang_config->{'buttons'}->{$language}->{'send'};
my $response_from_label = $c->lang_config->{'labels'}->{$language}->{'response_from'}.
' <b class="nickname">'.$c->session('client')->[1].'</b>:' if( $client_check );

my $comment_inappropriate = '<i class="comment_hidden"></i>';
my $reply_frase = lc $c->lang_config->{'reply'}->{$language};
my $change_frase = lc $c->lang_config->{'change'}->{$language};
my $comment_prefix  = $c->top_config->{'comment_prefix'};
my $admin_check     = $c->sess_check->admin( $c );
my $date_now = Mojo::Date->new( $c->db_table->now($c) )->epoch;

my $edit_link_admin = "";
my $status = '';
my $url = $c->req->url;
eval{ $client_id = $c->session('client')->[0]; };
$client_id = "" if(!$client_id);

foreach my $data(@subs_content){ #---------------
my( $user_id, $id_coomment_accord, $more_button_div_id, 
    $deviation_class, $comment_date, $date_diff, $banned_status );
my $edit_link_comment_client = "";
my $style_comment = ' class="'.$pClass.'"';
my $ban_frase = '';

    if( $c->menu->find( $table_users, 
                        ['view_status'], 
                        {'login' => $data->{'nickname'}})->list eq 'no' ){
        next;
    }
    $user_id = $c->menu->find( $table_users, 
                               ['id'], 
                               {'login' => $data->{'nickname'}})->list; 
    $banned_status = $c->menu->find( $table_users, 
                                     ['banned'], 
                                     {'login' => $data->{'parent_nickname'}})->list;

    if($banned_status){
      $ban_frase = '<b style="color:red">[ban]</b>';
    }

    my $share_alt_obj = "";
    if( $data->{'parent_id'} ){ 
        $share_alt_obj = "<span class=\"parent_nickname\"><span class=\"glyphicon glyphicon-share-alt\"></span>
        <a href=\"${url}#$comment_prefix$data->{'parent_id'}\">$data->{'parent_nickname'} $ban_frase</a></span>\n";
    }
    
    if( $last_insert_id eq $data->{'id'} ){
        $style_comment = substr( $style_comment, 0, length($style_comment)-1 ).' recent_comment"';
    }
    
    if( $admin_check ){
        $edit_link_admin = ' <span class="separator">|</span> <a class="arch_link" href="/user.comment?id='.$data->{'id'}.'&user_id='."$user_id\"> ".$c->lang_config->{'edit'}->{$language}."</a>\n";
    }

    $comment_date = $data->{'curr_date'};
    $date_diff = $date_now - Mojo::Date->new($comment_date)->epoch;
    $comment_date = $c->date_format($date_diff, $comment_date);  
    $id_coomment_accord = $data->{'id'}.'_comment';
    $more_button_div_id = 'moreDiv'.$comment_prefix.$data->{'id'};
    $deviation_class = ' dev'.$data->{level};
    
my $like_id = 'like_'.$data->{'id'};
my $unlike_id = 'unlike_'.$data->{'id'};
my $like_btn_name = 'like'.$data->{'id'};
my $unlike_btn_name = 'unlike'.$data->{'id'};
my $liked_cnt = $data->{'liked'} || 0;
my $unliked_cnt = $data->{'unliked'} || 0;

if( !$client_check ){
    $status = ' disabled';
}elsif(defined $c->signed_cookie('user'.$client_id.'_'.$data->{'id'}) && 
    $c->signed_cookie('user'.$client_id.'_'.$data->{'id'}) == $data->{'id'}){
    $status = ' disabled';
}

my $like_unlike_block = $c->like_unlike_block( $like_btn_name,
                                            $unlike_btn_name,
                                            $data->{'id'},
                                            $like_id,
                                            $unlike_id, 
                                            $client_id, 
                                            $status, 
                                            $liked_cnt, 
                                            $unliked_cnt
                                           );

my $disabled_like_unlike_block = $like_unlike_block;
if( $client_check ){
    $disabled_like_unlike_block = '';
}
my $user_comment_list_href = '/view.user?id='.$user_id;
if( $data->{'press_indicat'} eq 'no' ){

$comments.=<<COMM;
<div class="comment_block$deviation_class" id="$comment_prefix$data->{'id'}" name="$comment_prefix$data->{'id'}">
<p$style_comment>
$data->{'comment'}
</p>
COMM

}else{
$data->{'comment'} = decode('utf8', $data->{'comment'}) || $data->{'comment'};
$comments.=<<COMM;
<div class="comment_block$deviation_class" id="$comment_prefix$data->{'id'}" name="$comment_prefix$data->{'id'}">
<a href="$user_comment_list_href"><span class="nickname">$data->{'nickname'}</span></a>
<span class="date_comment">$comment_date</span>
$share_alt_obj
$edit_link_admin
<p$style_comment>
$data->{'comment'}
</p>
$disabled_like_unlike_block
COMM

}

if( $client_check ){     
    if( $data->{'level'} < $max_level ){
        $next_level = $data->{'level'} + 1;
    }else{
        $next_level = $data->{'level'};
    }
    
#*****************************
if( $user_id == $c->session('client')->[0] && ($data->{'comment'} ne $c->lang_config->{'comment_deleted'}->{$language})  
    && !($data->{'comment'} =~ /$comment_inappropriate/) ){ 
#*****************************
$data->{'comment'} = decode('utf8', $data->{'comment'}) || $data->{'comment'};
my $id_edit_coomment_accord = $data->{'id'}.'_edit';

$edit_link_comment_client = $c->edit_link_comment_client($id_edit_coomment_accord,
                                                         $change_frase,
                                                         $url,
                                                         $comment_prefix,
                                                         $data->{'id'},
                                                         $page_id,
                                                         $next_level,
                                                         $response_from_label,
                                                         $data->{'comment'},
                                                         $button_val
                                                        );


}#**************
else{
  $edit_link_comment_client = "";
}

#$edit_link_comment_client = ""; # Disable user`s comment editing for users

if( $data->{'comment'} ne $c->lang_config->{'comment_deleted'}->{$language} 
    && !($data->{'comment'} =~ /$comment_inappropriate/) ){
    
$comments .= $c->comment_bottom($id_coomment_accord,
                                $reply_frase,
                                $like_unlike_block,
                                $edit_link_comment_client,
                                $url,
                                $comment_prefix,
                                $data->{'id'},
                                $page_id,
                                $next_level,
                                $response_from_label,
                                $button_val
                               );

}
}
$comments.="<hr>\n</div>\n<div id=\"$more_button_div_id\"></div>\n";

    if( $data->{subs} ){
        my $subcomments = __PACKAGE__->select_including( $c, $data->{subs}, $table_users, $page_id, $last_insert_id, $pClass );
		$comments.=$subcomments;
	}
$status = '';    
} # foreach ----------------------

return $comments;
}#-------------

1;