package MyBlog::Tag;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim);

#---------------------------
sub select_form {
#---------------------------
my($self, $c, $data_ref, $data_exist, $name_select, $lang_config, $lang) = @_;
my $selected = "";
my $label_name = $c->lang_config->{'labels'}->{$lang}->{$name_select};
my $select=<<HTML;
<label for="$name_select" class="col-sm-6 control-label" style="text-align:right">
$label_name
</label>
<div class="col-md-2">
<select class="form-control" id="$name_select" name="$name_select">
HTML

foreach my $item(@$data_ref){
    if($item eq $data_exist){
        $selected = ' selected';
    }
$select.=<<HTML;
<option value="$item"$selected> $item
HTML

$selected = "";
}
$select.="</select>\n</div><br><br>\n";
return $select;
}#------------

#---------------------------
sub carousel_queue {
#---------------------------
my($self, $c, $lang, $slideshow_table, $image_queue, $image_id) = @_;
my $lang_mod = "'".$lang."'";
my $queue_select = '<select class="form-control" id="queue'.$image_id.
'" onchange="queueChange'.$image_id.'('.$image_id.', '.$lang_mod.')">'."\n";
my $selected = "";
my $count_rows = scalar( @{$c->menu->find( $slideshow_table, 
                                           ['queue'], 
                                           {}
                                         )->hashes} );

foreach my $que( 1..$count_rows ){
    if($que == $image_queue){
        $selected = ' selected';
    }
$queue_select.=<<HTML;
<option value="$que"$selected> $que
HTML

$selected = "";
}
$queue_select.='</select>';
return $queue_select;
}#------------
1;