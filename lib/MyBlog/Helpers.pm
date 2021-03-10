package MyBlog::Helpers;
use base 'Mojolicious::Plugin';
use Mojo::Base -base;

sub register {
    my ($self, $app) = @_;

    $app->helper( protocol => sub { my $c = shift; 
                                    if( $c->req->headers->header('X-Forwarded-Proto')){ 
                                        return 'https';
                                    }return 'http';
                                     } );

    $app->helper( decode_Pg => sub { my($self, $string) = @_ if(@_); return Moj::Util->decode_Pg($string) } );
    $app->helper( decode_mysql => sub { my($self, $string) = @_ if(@_); return Moj::Util->decode_mysql($string) } );
    $app->helper( encode_Pg => sub { my($self, $string) = @_ if(@_); return Moj::Util->encode_Pg($string) } );
    $app->helper( encode_mysql => sub { my($self, $string) = @_ if(@_); return Moj::Util->encode_mysql($string) } );
    $app->helper( path => sub { my($self, $path) = @_ if(@_); return Moj::Util->path($path) } );
    $app->helper( _validation => sub { my($c, $required_fields) = @_; 
                                        my $v = $c->validation;
                                        foreach my $item( @$required_fields ){
                                            $v->required($item, 'not_empty');
                                        }
                                        return $v; 
                                     } );
    $app->helper( date_format => 
    sub { my($c, $date_diff, $comment_date) = @_; 
    if ($date_diff < 60){
        return '&nbsp;'.int($date_diff).' '.$c->lang_config->{time_ago_comment}->{less_minute}->{$c->language}.'&nbsp;';
    }elsif($date_diff < 3600){
        return '&nbsp;'.int($date_diff/60).' '.$c->lang_config->{time_ago_comment}->{less_hour}->{$c->language}.'&nbsp;';
    }elsif($date_diff < 3600*24){
        return '&nbsp;'.int($date_diff/3600).' '.$c->lang_config->{time_ago_comment}->{less_day}->{$c->language}.'&nbsp;';
    }elsif($date_diff < 3600*24*30){
        return '&nbsp;'.int($date_diff/3600/24).' '.$c->lang_config->{time_ago_comment}->{less_month}->{$c->language}.'&nbsp;';
    }else{
        my @data_arr = split(/-/, substr( $comment_date, 0, 10 ));
        my $year = splice(@data_arr, 0, 1);
        return join('.', reverse(@data_arr)).'.'.$year;       
    }
    } );
    $app->helper(valid_img_format => sub {['.jpg', '.gif', '.png', '.bmp']});
    $app->helper(valid_img_brand_format => sub {['.png']});
    $app->helper(valid_img_favicon_format => sub {['.png', '.ico']});
    $app->helper(valid_doc_format => sub {['.doc', '.docx', '.rtf', '.pdf', '.txt', '.rar', '.zip', '.tar', '.7z']});
    $app->helper(valid_media_format => sub {['.aac', '.mp3', '.mp4', '.webm']});
    
    $app->helper(language => sub{ my $self = shift; $self->slurp( $self->top_config->{'lang_file'} ) } );
    
    $app->helper( like_unlike_block => sub { my $self = shift;
        my( $like_btn_name, $unlike_btn_name, $id, $like_id, $unlike_id, 
            $client_id, $status, $liked_cnt, $unliked_cnt) = @_;
            
        return <<LIKEUNLIKE;
<button type="button" name="$like_btn_name" class="btn btn-default" 
onclick="Like('$id', '$like_id', '$client_id', '$unlike_btn_name'); this.disabled='disabled';" id="chevron_stl"$status>
<span class="glyphicon glyphicon-chevron-up" aria-hidden="true"></span>
</button>
<span id="$like_id" class="like_unlike">$liked_cnt</span>
<button type="button" name="$unlike_btn_name" class="btn btn-default" 
onclick="Unlike('$id', '$unlike_id', '$client_id', '$like_btn_name'); this.disabled='disabled';" id="chevron_stl"$status>
&nbsp;<span class="glyphicon glyphicon-chevron-down" aria-hidden="true"></span>
</button>&nbsp;
<span id="$unlike_id" class="like_unlike">$unliked_cnt</span>
LIKEUNLIKE

#return $like_unlike_block; 
    } );
    
    $app->helper( edit_link_comment_client => sub { my $self = shift;
        my( $id_edit_coomment_accord, $change_frase, $url,$comment_prefix,
            $id, $page_id, $next_level, $response_from_label, $comment,
            $button_val) = @_;
            
        return <<EDIT;
<span class="separator">|</span>
<a class="arch_link" data-toggle="collapse" data-parent="#accordion" href="#$id_edit_coomment_accord">
 $change_frase
</a>
<div id="$id_edit_coomment_accord" class="panel-collapse collapse">
    <div class="panel-body">
    <form action="$url" method="post">
    <input type="hidden" name="redirect_to" value="$url#$comment_prefix$id">
    <input type="hidden" name="page_id" value="$page_id">
    <input type="hidden" name="level" value="$next_level">
    <input type="hidden" name="parent_id" value="$id">
    $response_from_label
    <br>
    <textarea name="edit_answ" class="form-control" rows="5" maxlength="3000" id="textar_answ">$comment</textarea>
    <input type="submit" name="edit_respons" class="btn btn-default btn-sm active" id="enter_button" value="$button_val">
    </form>
    </div>
</div>
EDIT
 
    } );
    
    $app->helper( comment_bottom => sub { my $self = shift;
        my( $id_coomment_accord,
            $reply_frase,
            $like_unlike_block,
            $edit_link_comment_client,
            $url,
            $comment_prefix,
            $id,
            $page_id,
            $next_level,
            $response_from_label,
            $button_val) = @_;
            
        return <<COMM;
<a class="arch_link" data-toggle="collapse" data-parent="#accordion" href="#$id_coomment_accord">
$reply_frase
</a>
<span class="separator">|</span>&nbsp;&nbsp;
$like_unlike_block
$edit_link_comment_client
<div id="$id_coomment_accord" class="panel-collapse collapse">
    <div class="panel-body">
    <form action="$url" method="post">
    <input type="hidden" name="redirect_to" value="$url#$comment_prefix$id">
    <input type="hidden" name="page_id" value="$page_id">
    <input type="hidden" name="level" value="$next_level">
    <input type="hidden" name="parent_id" value="$id">
    $response_from_label
    <br>
    <textarea name="answer" class="form-control" rows="5" maxlength="3000" id="textar_answ"></textarea>
    <!--<textarea name="answer$id" class="form-control" rows="5" maxlength="3000" id="textar_answ$id"></textarea>-->
    <input type="submit" name="send_answ" class="btn btn-default btn-sm active" id="enter_button" value="$button_val">
    </form>
    </div>
</div>
COMM

    } );
}

1;