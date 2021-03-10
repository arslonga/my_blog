package MyBlog::Logo;
use strict;
use warnings;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(decode encode trim);
use IO::File;
use List::Util qw(max);
use Mojo::Asset::File;
use MyBlog::Tag;
use DeleteFile;
use RewriteImage;

#------------------------------------
sub set_brand {
#------------------------------------
my $self = shift;
use Cwd;

my($img_format_err, $exist_brand_img, $indicr, $margin_top, $margin_left, 
$margin_right, $max_height);
my $language = $self->language;
my $template = $self->template;
my $templ = lc($template).'/set_brand';
my $brand_path = $self->top_config->{'brand_path'};
my $brand_image = $self->top_config->{'brand_image_name'};
my $list_of_brand_margin_values = $self->top_config->{'brand_margin_list'};
my $brand_max_height_values = $self->top_config->{'brand_max_height_list'};
my $brand_max_height_file = $self->top_config->{'brand_max_height_file'};
my $brand_margin_top_file = $self->top_config->{'brand_margin_top_file'};
my $brand_margin_left_file = $self->top_config->{'brand_margin_left_file'};
my $brand_margin_right_file = $self->top_config->{'brand_margin_right_file'};
my $brand_css_path = 'public/'.$self->top_config->{'brand_css_path'}.'/brand.css';
my $brand_templ = lc($template).'/'.$self->top_config->{'brand_templ_file'};
my $RewrImag = RewriteImage->new;
my $cwd = cwd();

#******************************
if($self->param('set_brand')){
#******************************
    if($self->req->upload('brand_img')->size > 0){
        my $upload_obj = $self->req->upload('brand_img');
        my $uploaded_filename = $upload_obj->filename;
        if($uploaded_filename){
        $uploaded_filename =~ /(\.\w+)$/;
    foreach my $valid_format( @{$self->valid_img_brand_format} ){
        if(lc($1) eq $valid_format){ 
            $indicr = 1;
            last;
        }
        $indicr = 'err';
    }
    if($indicr eq 'err'){
            $img_format_err = $uploaded_filename.' : '.
            $self->lang_config->{'alert'}->{$language}->{'invalid_brand_format'};
        }else{
            $img_format_err = '';
        }
    }
    $self->stash(template => $templ, img_format_err => $img_format_err);
if($img_format_err){
# Go to rendering template with error message
goto M;
}
        $upload_obj->move_to("public/$brand_path/$brand_image");
        $RewrImag->illustration( $self, $cwd.'/public/'.$brand_path, $brand_image, 'brand' );
        
    }
$self->spurt($self->param('margin_top'), $brand_margin_top_file);
$self->spurt($self->param('margin_left'), $brand_margin_left_file);
$self->spurt($self->param('margin_right'), $brand_margin_right_file);
$self->spurt($self->param('max_height'), $brand_max_height_file);
$self->redirect_to($self->url_for("setbrand"));
}#*************

M:
eval{
$margin_top   = $self->slurp($brand_margin_top_file);
$margin_left  = $self->slurp($brand_margin_left_file);
$margin_right = $self->slurp($brand_margin_right_file);
$max_height   = $self->slurp($brand_max_height_file);
};
$margin_top = 0 if(!$margin_top);
$margin_left = 0 if(!$margin_left);
$margin_right = 0 if(!$margin_right);

my $brand_css_content = $self->render_to_string(
template => $brand_templ,
margin_top => $margin_top,
margin_left => $margin_left,
margin_right => $margin_right,
max_height => $max_height
);
$self->spurt($brand_css_content, $brand_css_path);

$self->render(
template => $templ,
language => $language,
img_format_err => $img_format_err,
exist_brand_img => $brand_image,
exist_margin_top => $margin_top,
exist_margin_left => $margin_left,
exist_margin_right => $margin_right,
exist_max_height => $max_height,
brand_margin_list => $list_of_brand_margin_values,
brand_max_height_list => $brand_max_height_values,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'brand'}->{$language},
head => $self->lang_config->{'brand'}->{$language}
);
}#-------------

#------------------------------------
sub logo_set_img {
#------------------------------------
my $self = shift;
use Cwd;

my($message, $result, $width, $height);
my $language = $self->language;
my $template = $self->template;
my $templ = lc($template).'/logo_set_img';
my $logo_type_file = $self->top_config->{'logo_type_file'};
my $logo_title_file = $self->top_config->{'logo_title_file'};
my $logo_motto_file = $self->top_config->{'logo_motto_file'};
my $logo_img_file = $self->top_config->{'logo_img_file'};
my $logo_image_path = $self->top_config->{'logo_image_path'};
my $logo_image_filename = $self->top_config->{'logo_image_filename'};
my $head_templ_file = $self->top_config->{'head_templ_file'};
my $logo_img_templ_file = $self->top_config->{'logo_img_template'};
my $head_conf_set = $self->top_config->{'logo_head_file'};
my $RewriteImage = RewriteImage->new;

#******************************
if($self->param('set_type')){
#******************************
    if($self->param('logo_img')){

        if($self->req->upload('logo_img')->size == 0){
        goto NE;
        }
    
        my $cwd = cwd();
        my $upload_obj = $self->req->upload('logo_img');
        $upload_obj->move_to("public/$logo_image_path/$logo_image_filename");
        ($result, $width, $height) = 
        $RewriteImage->logo_img($self, "$cwd/public/$logo_image_path", $logo_image_filename);
        ($width, $height) = ($width/2, $height/2);
        
     $self->redirect_to($self->url_for('logo.set_img'));   
    }
NE:
}#*************

my $exist_logo_type = $self->slurp( $logo_type_file );

my $output = $self->render_to_string(
template => $logo_img_templ_file,
logo_image_path => $logo_image_path,
logo_image_filename => $logo_image_filename
);
$self->spurt($output, $head_conf_set);

$self->render(
template => $templ,
language => $language,
message => 'OK!',
exist_logo_type => $exist_logo_type,
exist_logo_img => '<img src="/'.$logo_image_path.'/'.$logo_image_filename.'" width="50%">',
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
head => $self->lang_config->{'logo_setting'}->{$language}
);
}#-------------

#------------------------------------
sub logo_set_slideshow {
#------------------------------------
my $self = shift;
my($top_config, $lang_config, $lang) = @_;

use Cwd;

my( $message, @exist_images, $slide_image_filename, $data_interval_exist, 
    $transition_duration_exist, $height_fit_exist, $data_interval_form, 
    $transition_duration_form );
my $language = $self->language;
my $template = $self->template;
my $templ = lc($template).'/logo_set_slideshow';
my $slideshow_table = $self->top_config->{'table'}->{'slideshow'};
my $transition_duration_ref = $self->top_config->{'transition_duration'};
my $data_interval_ref = $self->top_config->{'data_interval'};
my $transition_duration_file = $self->top_config->{'transition_dur_file'};
my $data_interval_file = $self->top_config->{'data_interval_file'};
my $height_fit_file = $self->top_config->{'height_fit_file'};
my $css_file_path = $self->top_config->{'css_file_path'};
my $css_file_path2 = $self->top_config->{'_css_file_path'};

my $logo_type_file = $self->top_config->{'logo_type_file'};
my $slides_file = $self->top_config->{'slides_file'};
my $slides_image_path = $self->top_config->{'slides_image_path'};
my $slidename_pattern = $self->top_config->{'name_pattern'}->{'slide'};
my $slideshow_templ_file = $self->top_config->{'slideshow_template'};
my $head_conf_set = $self->top_config->{'logo_head_file'};
my $Directory; # = "$dir_domen/$prefix/$slides_image_path";
my $RewriteImage = RewriteImage->new;
my $cwd = cwd();  

#******************************
if($self->param('upload_slide')){
#******************************
    if($self->req->upload('slide_img')->size > 0){
        my $slide_name = $self->menu->find( $slideshow_table, 
                                            ['image_file'], 
                                            {id => $self->param('image_id')}
                                          )->list;
        my $cwd = cwd();
        my $upload_obj = $self->req->upload('slide_img');
        $upload_obj->move_to("public/$slides_image_path/$slide_name");
        my($result, $width, $height) = 
        $RewriteImage->slide_img($self, "$cwd/public/$slides_image_path", $slide_name);
    }
$self->redirect_to($self->url_for("/logo.set_slideshow"));
}#*************

#******************************
if($self->param('slide_id')){
#******************************
$self->menu->save( $slideshow_table, 
                   {queue => $self->param('queue')}, 
                   {id => $self->param('slide_id')}
                 );
}#*************

#******************************
if($self->param('del_slide')){
#******************************
DeleteFile->new->delete_slide($self);
$self->redirect_to($self->url_for("/logo.set_slideshow"));
}#*************

#******************************
if($self->param('set_type')){
#******************************
    if($self->req->upload('new_slide')->size == 0){
        goto NE;
    }
    else{
        my @slides = $self->menu->find($slideshow_table, ['image_file'])->flat;

        foreach(@slides){
            $_ = (split(/\./, (split(/\_/, $_))[1] ))[0];
        }
        my $max_numb_of_slidename = max(@slides);
        $max_numb_of_slidename++;
        $slide_image_filename = $slidename_pattern.$max_numb_of_slidename.'.jpg'; # $slidename_pattern = 'slide_'
        $self->menu->create( $slideshow_table, 
                             {
                              image_file => $slide_image_filename, 
                              queue => $max_numb_of_slidename
                             }
                           );        
        my $cwd = cwd();
        my $upload_obj = $self->req->upload('new_slide');
        $upload_obj->move_to("public/$slides_image_path/$slide_image_filename");
        my($result, $width, $height) = 
        $RewriteImage->slide_img($self, "$cwd/public/$slides_image_path", $slide_image_filename);
    }

NE:
$self->spurt($self->param('data_interval'), $data_interval_file);
my $css_cont = $self->slurp($css_file_path);

#+++++++++++++++++++++++++++++++++++++++++++
if ( open( my $fh, $cwd.'/'.$css_file_path ) ) {
  my @arr_lines = <$fh>;
  map{
        if( $_ =~ /\/\*TRANSITION\_DURATION\*\// ){ 
            $_ = 'transition-duration:'.$self->param('transition_duration').'; -webkit-transition-duration:'.$self->param('transition_duration').'; -o-transition-duration:'.$self->param('transition_duration').";/*TRANSITION_DURATION*/\n";
        }
     } @arr_lines;
     
open(FILE, ">>$cwd".'/'."$css_file_path") || die "Open file error $cwd.'/'.$css_file_path: $!\n";
seek FILE,0,0;
truncate FILE,0;
print FILE @arr_lines;
close(FILE);

} else {
  warn "Could not open file $cwd.'/'.$css_file_path $!";
}
#+++++++++++++++++++++++++++++++++++++++++++ 

$self->spurt( $self->param('transition_duration'), $transition_duration_file );
$self->spurt( $self->param('height_fit'), $height_fit_file );
$self->redirect_to( $self->url_for('logo_set_slideshow') );
}#*************
eval{
    $data_interval_exist = $self->slurp($data_interval_file);
    $transition_duration_exist = $self->slurp($transition_duration_file);
    $height_fit_exist = $self->slurp($height_fit_file);
};

my @FILES = $self->menu->find($slideshow_table, ['image_file'], {}, 'queue')->flat;
my $slides_ref = $self->menu->find($slideshow_table, ['*'], {}, 'queue')->hashes;

my $exist_logo_type = decode 'utf8', $self->slurp($logo_type_file);

my $output = $self->render_to_string(
template => $slideshow_templ_file,
slides_arr => \@FILES, 
slides_image_path => $slides_image_path,
data_interval => $data_interval_exist
);

$self->spurt($output, $head_conf_set);

$self->render(
template => $templ,
language => $language,
slideshow_table => $slideshow_table,
exist_logo_type => $exist_logo_type,
slides_ref => $slides_ref,
slides_image_path => $slides_image_path,
data_interval_ref => $data_interval_ref,
data_interval_exist => $data_interval_exist,
transition_duration_ref => $transition_duration_ref,
transition_duration_exist => $transition_duration_exist,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
head => $self->lang_config->{'logo_setting'}->{$language}
);
}#-------------
1;