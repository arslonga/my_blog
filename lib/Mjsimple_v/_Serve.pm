package Serve;
use Mojo::Base -base; # 'Mojolicious::Controller';
use Mojo::Util qw(trim);
use Mjsimple_v::MenuClient;

has 'db';
has 'menu';

#----------------------------------------------
sub new{
#----------------------------------------------
   my $proto = shift;
   my $class = ref($proto) || $proto;
   my $self = {};
   bless($self, $class);
return $self;
}#-------------

#---------------------------------
sub err_hash_fields{
#---------------------------------
my($self, $c, $arr_ref, $message) = @_;
my %err_hash;
my $language = $c->language;
my $empty_field_mess = $c->lang_config->{'empty_field'}->{$language} || 'Empty field';

    foreach(@$arr_ref){
        # Message about empty form field
        $err_hash{$_} = $empty_field_mess if( !trim($c->param($_)) );
    }

return %err_hash;
}#--------

#---------------------------------
sub err_hash_fields_comments{
#---------------------------------
my($self, $c, $arr_ref, $message) = @_;
my %err_hash;
my $language = $c->language;
my $client_id;
eval{ $client_id = $c->session('client')->[0]; };
my $client_check = $c->sess_check->client( $c, $client_id );
my $empty_field_mess = $c->lang_config->{'empty_field'}->{$language} || 'Empty field';

    foreach(@$arr_ref){
        if($_ eq 'log_in' || $_ eq 'passw'){
            my $val = trim($c->param($_));
            $val = $c->session('client')->[1] if( !$val && $client_check );
            # Message about empty form field
            $err_hash{$_} = $empty_field_mess if(!$val);
        }else{
            $err_hash{$_} = $empty_field_mess if(!$c->param($_));
        }
    }

return %err_hash;
}#--------

#---------------------------------
sub err_hash_fields_plus{
#---------------------------------
my($self, $c, $arr_ref, $message) = @_;
my %err_hash;
my $empty_field_mess = $message;

        $err_hash{$arr_ref} = $empty_field_mess; # if(!$c->param($_));

return $err_hash{$arr_ref};
}#--------

#----------------------------------
sub get_menu{
#----------------------------------
my($self, $c, $ref_hash_dir_subs) = @_;

return Mjsimple_v::MenuClient->menu($c, $ref_hash_dir_subs);
}#--------------

#----------------------------------
sub menu_rewrite{
#----------------------------------
my($self, $c, $menu) = @_;
my(@urls);

my @work_arr = sort @{$c->top_config->{'levels'}};
pop @work_arr;

foreach my $table( @work_arr ){
 
    my $result = $c->menu->find( $table, ['url', 'id', 'in_menu'], {children => undef}  );
        while( my($pattern, $id, $in_menu) = $result->list ){
            my $pattern_mod = '<a href="'.$pattern.'">';
            $pattern_mod = '<a class="activ" href="'.$pattern.'">' if($in_menu eq 'no');
        
            if( $table eq 'level0' || $table eq 'level1' ){
                my $curr_menu = $menu;
                    $curr_menu =~ /($pattern_mod)/;
                if($in_menu eq 'no'){
                    $curr_menu =~ s/$pattern_mod//;
                }else{
                    $curr_menu =~ s/$1/<a class\=\"activ\" href=\"$pattern\">/;
                }
                $c->menu->save( $table, {menu => $curr_menu}, {id => $id} );
            }else{
                $c->menu->save( $table, {menu => $menu}, {id => $id} );
            }
        
        }
}
#=============================================
foreach my $table( sort @{$c->top_config->{'levels'}} ){ 
    my $result = $c->menu->find( $table, ['url', 'id', 'in_menu'], {children => 'yes'}  );
        while( my($pattern, $id, $in_menu) = $result->list ){
            push @urls, $pattern;
        }
}

foreach my $item(@urls){
    my $loc_table = substr($item, 1);
    my $level_id = $c->menu->find( substr($item, 1), ['level_id'] )->list;
    my $res_arr = $c->menu->find( 'level2', ['id', 'url'], { url => {-like => $item.'%'} } );
    while( my($id, $curr_url) = $res_arr->list ){
        #say $id, ' ', $level_id;
        my $curr_menu = $menu;
        if($curr_menu =~ /<a\s+class="collp" id="_(coLLapse$level_id)">/){
            my $id_patrn = $1;
            $curr_menu =~ s/<div (id\=\"$id_patrn\" class\=\"paNel-coLLapse coLLapse)\">/<div $1 iN\" style=\"animation-duration: 0s;\">/; 
            $curr_menu =~ s/<span (id\=\"$level_id\" class\=\"chevron right)\">/<span $1 bottom\">/; 
            $curr_menu =~ s/<a href\=\"$curr_url\">([^<>]*)<\/a>/<a href\=\"$curr_url\"><b>$1<\/b><\/a>/; 
            $c->menu->save( 'level2', {menu => $curr_menu}, {id => $id} );
        }
    }
}
return 1;
}#--------------

#-------------------------------------
sub select_struct {
#-------------------------------------
my($c, $self, $levels_arr_ref) = @_;
my(%hash_dir_subs, %hash_level_parent_dir);

# Iterating array of table names of menu levels
foreach my $curr_level(@$levels_arr_ref){ #####
	
my @parent_dir = ();

# Let form an array of unique values '@parent_dir' of parent directories from the table of the current level
my $result = $self->menu->find($curr_level, 'distinct(parent_dir)'); # ORDER BY queue ]);

while(my $item = $result->list){
   push @parent_dir, $item;
}

my @hashref_arr = ();

foreach my $curr_parent_dir(@parent_dir){
    my $result = $self->menu->find($curr_level, ['*'], {'parent_dir' => $curr_parent_dir}, 'queue');
    while(my $hashref = $result->hash){

    $hashref->{level} = $curr_level;
        if( $hash_dir_subs{$hashref->{'title_alias'}} ){
            $hashref->{subs} = $hash_dir_subs{$hashref->{'title_alias'}};
            my $title_alias = $hashref->{'title_alias'};
		
            # For sections that have nested sections, set list_enable = 'no' (one-page section).
            # This is actually the index page of the section, which contains an annotation to the children sections
            $self->menu->save($curr_level, {list_enable => 'no'}, {title_alias => $title_alias}) if($curr_level ne 'level0');
        }
        push @hashref_arr, $hashref;
    }

}
my @subs_arr = ();

foreach my $curr_parent_dir(@parent_dir){
	foreach(@hashref_arr){
		if($_->{parent_dir} eq $curr_parent_dir){
		push @subs_arr, $_;
		}else{
			@subs_arr = ();
			next;
		}		
		$hash_dir_subs{$curr_parent_dir} = [@subs_arr];
	}
}	

} #####
return \%hash_dir_subs;
}#----------

#-------------------------------------------------
sub get_menu_form {
#-------------------------------------------------
my($self, $c, $data, $form_name) = @_;
my $language = $c->language;
my $menu_form;
my $deviation = 50;
my $select_attr = "";
my $edit_frase = $c->lang_config->{'buttons'}->{$language}->{'save'};
my $queue_frase = $c->lang_config->{'queue'}->{$language};
my $multipage = $c->lang_config->{'multipage'}->{$language};

my $empty_field_alert = $c->lang_config->{'empty_field'}->{$language};
my $new_chapter_label = $c->lang_config->{'labels'}->{$language}->{'new_chapter'};
my $index_for_subs_label = $c->lang_config->{'labels'}->{$language}->{'index_for_subs'};
my $max_level           = $c->top_config->{'max_level'};
my $del_frase           = $c->lang_config->{'delete'}->{$language};
my $add_new_chapter_frase = $c->lang_config->{'new_chapter_add'}->{$language};
my $content_frase       = $c->lang_config->{'content'}->{$language};
my $new_chapter_frase   = $c->lang_config->{'labels'}->{$language}->{'new_chapter'};
my $not_view_in_menu    = $c->lang_config->{'not_view_in_menu'}->{$language};
my $decode_action = 'decode_'.$c->db_driver;

my $templ_without_list_checked = '';
my $templ_list_checked = '';

my $checkbox_form=<<FORM;
<div class="form-group">
    <div class="col-sm-4">
      <div class="checkbox">
        <label id="delete_chbox">
<input type="checkbox" name="del_chapter" value="yes"> $del_frase   
        </label>
    </div>
  </div>
</div>
FORM

$checkbox_form = "" if( $data->{'level'} eq 'level0' );
my $templ_add_existed;
	
my $level_deviation = $deviation * (split(//, $data->{level}))[-1];
my $level_color = $c->top_config->{'block_color'}->{$data->{level}};

my($count_of_level) = $c->db_table->count_rws($c, $data->{level});
$data->{title} = $c->$decode_action( $data->{title} );

$menu_form.=<<HTML;
<div class="col-sm-12 menu_form" style="background-color: $level_color; margin-left: ${level_deviation}px">
<form method="post" action="/menu_manage" name="edit_$form_name" class="form-horizontal" role="form">

<div class="row">

<div class="col-sm-3" style="margin-left:10px; margin-right:10px">
  <div class="form-group">
  <input class="form-control" type="text" name="title" value="$data->{title}">
  </div>
</div>

<div class="col-sm-2">
  $checkbox_form
</div>

<div class="col-sm-2">
 <div class="form-group">
 &nbsp;&nbsp;&nbsp;&nbsp;<b>${queue_frase}:</b><br>
 <div class="col-sm-12">
  <select class="form-control" id="selectQueue" placeholder="selectQueue" size="1" name="queue">
HTML

for my $curr_queue( 1..$count_of_level ){
	$select_attr = 'selected' if($curr_queue eq $data->{queue});
	$menu_form.="<option value=\"$curr_queue\" $select_attr>$curr_queue\n";
	$select_attr = "";
}
$menu_form.=<<HTML;
</select>
</div>
</div>
 </div>
HTML

unless($data->{'title_alias'} eq 'main'){
my $in_menu_checked = '';
$in_menu_checked = 'checked' if($data->{in_menu} eq 'no');
$menu_form.=<<HTML;
<div class="col-sm-3">
 
<div class="form-group">
    <div class="col-sm-12">
      <!--<div class="checkbox" style="margin-left:-140px">-->
      <div class="checkbox">
        <label>
<input type="checkbox" name="out_menu" value="no" $in_menu_checked><b>$not_view_in_menu</b> 
        </label>
    </div>
  </div>
</div>

</div>
HTML

$in_menu_checked = "";
}
$menu_form.=<<HTML;
</div>
HTML

if( $data->{subs} && $data->{level} ne 'level0' ){
    # The Record that this section has nested sections
	$templ_add_existed = "<b style=\"color: blue\"><u>$index_for_subs_label</u></b>\n";
    $c->menu->save($data->{level}, {'children' => 'yes'}, {'id' => $data->{'id'}});
}else{
    if($data->{'list_enable'} eq 'yes'){$templ_list_checked = 'checked'}
    if($data->{'list_enable'} eq 'no'){$templ_without_list_checked = 'checked'}

	$templ_add_existed=<<HTML;
<div class="row">

<div class="col-sm-3">
Alias:<br>
<div style="margin-left:10px; margin-right:10px">
<div class="form-group">
<fieldset disabled>
<input class="form-control" id="existAlias" type="text" name="title_alias" value="$data->{title_alias}">
</fieldset>
</div>
</div>
</div>

<fieldset>
<div class="col-sm-4">
<div class="radio">
  <label class="radio-inline">
  <fieldset disabled>
    <input type="radio" name="list_enable" value="yes" $templ_list_checked> $multipage
  </fieldset>
  </label>
</div>
</div>

<div class="col-sm-4">
<div class="radio">
  <label class="radio-inline">
  <fieldset disabled>
<input type="radio" name="list_enable" value="no" $templ_without_list_checked> one page
  </fieldset>
  </label>
</div>
</div>
</fieldset>


</div>
HTML

}
	$data->{url} =~ s/^[\/]+//;

$menu_form.=<<HTML;
$templ_add_existed
<div>
HTML

if( ($data->{'list_enable'} eq 'yes' && $data->{level} ne 'level0') || ($data->{'list_enable'} eq 'no' && $data->{level} eq 'level0')){
$menu_form.=<<HTML;
description:<br>
<input class="form-control" type="text" name="description" value="$data->{description}">
keywords:<br>
<input class="form-control" type="text" name="keywords" value="$data->{keywords}">
HTML

}

$menu_form.=<<HTML;
<input type="hidden" name="id" value="$data->{'id'}">
<input type="hidden" name="template" value="$data->{'template'}">
<input type="hidden" name="level" value="$data->{level}">
<input type="hidden" name="url" value="/$data->{url}">
<input type="hidden" name="title_alias" value="$data->{'title_alias'}">
<input type="submit" class="btn btn-primary" style="margin-top:4px;" name="edit" value="$edit_frase">
</div>
</form>
HTML

if( !$data->{'subs'} || $data->{level} eq 'level0'){
    my $action = '/list_content_manage';
    $action = '/article_manage' if( $data->{'list_enable'} eq 'no' );
    $data->{'title'} = $c->$decode_action( $data->{'title'} );

$menu_form.=<<HTML;
<div id="kontent_button">
<br>
<form method="post" action="$action">

<input type="hidden" name="level_id" value="$data->{'id'}">
<input type="hidden" name="title" value="$data->{'title'}">
<input type="hidden" name="template" value="$data->{'template'}">
<input type="hidden" name="list_enable" value="$data->{'list_enable'}">
<input type="hidden" name="level" value="$data->{level}">
<input type="hidden" name="url" value="/$data->{url}">
<input type="hidden" name="title_alias" value="$data->{'title_alias'}">
<input type="hidden" name="direct" value="$data->{title_alias}">
<input type="submit" class="btn btn-info" name="add_publication" style="margin-left:100px;" value="$content_frase">
</form>
</div>
HTML

}

if( $data->{'level'} ne $max_level ){
my $attention;
if($data->{'children'} ne 'yes' && $data->{'level'} ne 'level0'){
    $attention = $c->lang_config->{'attention_add_chapter'}->{$language};
}

$menu_form.=<<HTML;
<form method="post" action="/menu_manage" name="$form_name" class="form-horizontal" role="form">
<div class="row">
<div class="form-group" id="mr_menu_download">
<b id="delete_chbox">$attention</b>
<div class="row">
    <div class="col-sm-5">
        <input class="form-control" type="text" name="new_title" placeholder="$new_chapter_frase">
    </div>
    <div class="col-sm-5">
        <input class="form-control" type="text" name="new_title_alias" placeholder="Alias (eng.):">
    </div>
</div>

<div class="row">    
  <div class="col-sm-2">
    <div class="radio">
        <label class="radio-inline">
        <input type="radio" name="new_list_enable" value="yes"> $multipage
        </label>
    </div>
  </div>
  <div class="col-sm-2">
    <div class="radio">
        <label class="radio-inline">
        <input type="radio" name="new_list_enable" value="no"> one page
        </label>
    </div>
  </div>
    
    <div class="col-sm-6" style="padding:2px">
    <div class="col-sm-3">
        <input type="submit" class="btn btn-success" name="add" value="$add_new_chapter_frase">
    </div>
    </div>
</div>
</div>

<input type="hidden" name="level" value="$data->{level}">
<input type="hidden" name="url" value="/$data->{url}">
<input type="hidden" name="title_alias" value="$data->{title_alias}">
</div>

</form>
HTML

}

$menu_form.="</div>\n";

return $menu_form;
}#---------------
1;