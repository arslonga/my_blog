package MyBlog::Manager;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(encode decode b64_encode trim);
use Moj::Util;
use Locale::Codes::Language;
use Mojo::File qw(path);
use Session;
use RewriteImage;

#---------------------------------
sub start {
#---------------------------------
my $self = shift;
my @levels;
my $table_rss_setting = $self->top_config->{'table'}->{'rss_setting'};
my $admin_check = $self->sess_check->admin($self);

my $rss_conf = $self->menu->find($table_rss_setting, ['*'])->hash;
if( !$rss_conf->{'title'} || !$rss_conf->{'description'} ){
    $self->redirect_to($self->url_for('/rss_setting')->query(err_config => 'yes'));
}
$self->redirect_to('admin') if !$admin_check;

if( $self->param('logout') ){
Session->admin_expire($self);
$self->redirect_to('/');
}

##############################################################################
#foreach my $level( @{$self->top_config->{'levels'}} ){
#    my $result = $self->menu->find($level, ['title_alias']);
#    while(my $table = $result->list){
#        say $level, ': ', "\$level \= $level";
#        $self->db->query(qq[ ALTER TABLE $level ADD COLUMN order_for_time VARCHAR(10); ]);
#        $self->db->query(qq[ UPDATE $level SET order_for_time = 'direct' WHERE list_enable = 'yes'; ]);
        #$self->db->query(qq[ ALTER TABLE "$table" ALTER COLUMN liked SET NOT NULL, ALTER COLUMN unliked SET NOT NULL; ]);
#   }
#}
#say '--------------------------------';
#$self->db->query(qq[ ALTER TABLE "auser" ADD COLUMN banned varchar(4); ]);
##############################################################################

$self->render(
title => $self->lang_config->{'labels'}->{$self->language}->{'masterroom'}
);
}#---------------

#---------------------------------
sub favicon {
#---------------------------------
my $self = shift;
use Cwd;

my($message, $img_format_err, $indicr, $result, $exist_favicon_img, $exist_favicon_code, 
$favicon_data, $extension);
my $language = $self->language;
my $template = $self->template;

my $logo_image_path = $self->top_config->{'logo_image_path'};
my $favicon_image_filename = $self->top_config->{'favicon_image_filename'};
my $favicon_image_templ_file = $self->top_config->{'favicon_img_template'};
my $favicon_code_templ_file = $self->top_config->{'favicon_code_template'};
my $favicon_image_file = $self->top_config->{'favicon_image_file'};
my $favicon_code_file = $self->top_config->{'favicon_code_file'};
my $RewriteImage = RewriteImage->new;

#******************************
if($self->param('favicon_img')){
#******************************

        if($self->req->upload('favicon_img')->size == 0){
        goto NE;
        }
    
        my $cwd = cwd();
        my $upload_obj = $self->req->upload('favicon_img');
        my $uploaded_filename = $upload_obj->filename;
        
        if( $uploaded_filename ){
            $uploaded_filename =~ /(\.\w+)$/;
            foreach my $valid_format( @{$self->valid_img_favicon_format} ){
                if(lc($1) eq $valid_format){ 
                    $extension = (split( /\./, lc($1) ))[1];
                    $indicr = 1;
                last;                
                }
                $indicr = 'err';
            }
            if($indicr eq 'err'){
                $img_format_err = $uploaded_filename.' : '.
                $self->lang_config->{'alert'}->{$language}->{'invalid_favicon_format'}.
                join(', ', map{ '\''.$_.'\'' } @{$self->valid_img_favicon_format});
            }else{
                $img_format_err = '';
            }
        }
        $self->stash( img_format_err => $img_format_err );
        if( $img_format_err ){
            # Go to rendering template with error message
            goto NE;
        }
        
        $upload_obj->move_to('public/'.$logo_image_path.'/'.$favicon_image_filename.'.'.$extension);
        $RewriteImage->illustration( $self, $cwd.'/public/'.$logo_image_path, $favicon_image_filename.'.'.$extension, 'favicon' );
        $favicon_data = b64_encode( $self->slurp( 'public/'.$logo_image_path.'/'.$favicon_image_filename.'.'.$extension ) );
        
        my $output_img = $self->render_to_string(
        extension => $extension,
        template => $favicon_image_templ_file,
        favicon_data => $favicon_data,
        );
        $self->spurt( $output_img, 'public/'.$favicon_image_file );
        
        my $output_code = $self->render_to_string(
        extension => $extension,
        template => $favicon_code_templ_file,
        favicon_data => $favicon_data,
        );
        $self->spurt( $output_code, 'public/'.$favicon_code_file );
         
     $self->redirect_to('/favicon');  
NE:
}#*************

eval{
$exist_favicon_img = $self->slurp( 'public/'.$favicon_image_file );
$exist_favicon_code = $self->slurp( 'public/'.$favicon_code_file );
};

$self->render(
language => $language,
message => 'OK!',
img_format_err => $img_format_err,
exist_favicon => $exist_favicon_img,
exist_favicon_code => $exist_favicon_code,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
head => 'Favicon'
);

}#---------------


#----------------------------
sub theme {
#----------------------------
my $self = shift;
my $theme_file = $self->top_config->{'css_theme_file'};
my $css_theme_path = $self->top_config->{'css_theme_path'};
my($ref_theme_color_list, $theme_css_content);

if($self->param('set_theme')){ #***********************
    $self->spurt( $self->param('theme'), $theme_file );
    $ref_theme_color_list = $self->top_config->{'color_themes'}->{$self->param('theme')};
    $theme_css_content = $self->render_to_string(
    template => lc($self->template).'/theme', 
    ref_theme_color_list => $ref_theme_color_list );
    $self->spurt( trim( trim( $theme_css_content ) ), $css_theme_path);
$self->redirect_to( $self->url_for( name => 'theme_manage'  ) );
} #***********************
my $current_theme = $self->slurp( $theme_file );
$self->render(
current_theme => $current_theme,
header => $self->lang_config->{'labels'}->{$self->language}->{'masterroom'},
title => $self->lang_config->{'theme'}->{$self->language},
head => $self->lang_config->{'theme'}->{$self->language},
);
}#---------

#---------------------------------
sub logo_manage {
#---------------------------------
my $self = shift;
my $logo_type_file = $self->top_config->{'logo_type_file'};

if($self->param('logo_type')){
    $self->spurt($self->param('logo_type'), $logo_type_file);    
    my $redirect = $self->top_config->{'redirect_logo'}->{$self->param('logo_type')};
$self->redirect_to("/$redirect");
}
my $exist_logo_type = $self->slurp( $logo_type_file );

$self->render(
exist_logo_type => $exist_logo_type,
title => $self->lang_config->{'labels'}->{$self->language}->{'masterroom'},
);
}#---------------

#---------------------------------
sub msg_manage {
#---------------------------------
my $self = shift;

my($message, @msg_files);
my $language = $self->language;
my $template = $self->template;
#my $templ = 'msg_format';
my $msg_format_file = 'conf/'.$language.'/'.$self->param('message') if($self->param('message'));

foreach my $filename( @{$self->msg_files} ){
   next if(!($filename =~ /msg/) || -d 'conf/'.$self->language.'/'.$filename);
   push @msg_files, $filename;
}

if($self->param('go')){
    $self->spurt(encode('utf8', $self->param('content')), $msg_format_file);
}

#************************
if($self->param('message')){
#************************
my $file_content = $self->slurp( $msg_format_file );

$self->render(
language => $language,
message => $self->param('message'),
file_content => decode('utf8', $file_content),
msg_files => [],
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'message_formats'}->{$language},
head => $self->lang_config->{'message_formats'}->{$language}
);
}else{ #**********

$self->render(
language => $language,
message => "",
file_content => "",
msg_files => [@msg_files],
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'message_formats'}->{$language},
head => $self->lang_config->{'message_formats'}->{$language}
);
}#**********
}#---------------

#----------------------------
sub authorize_setting {
#----------------------------
my $self = shift;
my $authorize_setting_file = $self->top_config->{'authorize_setting_file'};

if($self->param('set_auth_form')){
    $self->spurt($self->param('set_auth_form'), $authorize_setting_file);
}

my $authorize_setting = $self->slurp( $authorize_setting_file );

$self->render(
authorize_setting => $authorize_setting,
header => $self->lang_config->{'labels'}->{$self->language}->{'masterroom'},
title => $self->lang_config->{'authorize_form_showing'}->{$self->language},
head => $self->lang_config->{'show_authorize_form'}->{$self->language},
);
}#---------

#---------------------------
sub social_buttons {
#---------------------------
my $self = shift;
my $language = $self->language;
my $social_buttons_file = $self->top_config->{'social_buttons_file'};

if($self->param('set')){
    $self->spurt($self->param('share_buttons'), $social_buttons_file);
$self->redirect_to('/admin/social_buttons');
}
my $exist_share_buttons_code = $self->slurp($social_buttons_file);

$self->render(
language => $language,
exist_share_buttons_code => $exist_share_buttons_code,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'social_buttons'}->{$language},
head => $self->lang_config->{'social_buttons_code'}->{$language},
);
}#-------------

#---------------------------
sub local_transliter {
#---------------------------
my $self = shift;
my $language = $self->language;
my $transl_pkg_template = 'manager/transliter_pkg';
my $literalident_pkg_template = 'manager/literalident_pkg';
my $local_transliter_file = $self->top_config->{'local_transliter_file'};
my $lang_file = $self->top_config->{'lang_file'};
my $lang_file_js = $self->top_config->{'lang_file_js'};
my $transliter_package_file = 'lib/Transliter.pm';
my $literalident_package_file = 'lib/LiteralIdent.pm';
my $routines_file = $self->top_config->{'routines_file'};
my(@routines, %path, $site_lang, $path_file, $exist_local_transliter_code, $package_code, $local_symb, $latin_symb,
   %local, %latin, $reslt_transliter, $reslt_literalident);

#****************************
if($self->param('set')){
#****************************
    my $os = $^O;
    $site_lang = $self->param('sitelang');

eval{    
    $self->spurt( encode( 'utf8', trim( $site_lang ) ), $lang_file );
    $self->spurt( encode( 'utf8', trim( $site_lang ) ), 'public/'.$lang_file_js );
    my $path = Mojo::File->new('conf/'.$site_lang)->make_path;

    my $en_collection = Mojo::File->new('conf/en')->list;

    $self->copy_files_newlang($en_collection, $site_lang);
    
    @routines = split( /\|/, $self->slurp( $routines_file ) );

    foreach my $routn(@routines){
       $path{$routn} = Mojo::File->new( 'conf/'.$routn.'/'.$site_lang )->make_path;
       my $en_collection = Mojo::File->new('conf/'.$routn.'/en')->list;

       $self->copy_files_newlang($en_collection, $site_lang);
    }
};
    
    $self->spurt( encode( 'utf8', trim($self->param('local_transliter_code')) ), $local_transliter_file);
    my $cnt = 1;
    foreach my $pair (split("\n", $self->param('local_transliter_code'))){
        $pair =~ s/\s//g;
        $local{$cnt} = (split(/\:/, $pair))[0];
        $latin{$cnt} = (split(/\:/, $pair))[1];
    $cnt++;
    }
foreach my $key( sort {$a <=> $b} keys %local ){
    $local_symb.=$local{$key};
}
foreach my $key( sort {$a <=> $b} keys %latin ){
    $latin_symb.=$latin{$key};
}

$reslt_transliter = $self->render_to_string(
template => $transl_pkg_template,
local_symb => $local_symb,
latin_symb => $latin_symb
);

if( $site_lang ne 'uk' && $site_lang ne 'en' ){
#if( $site_lang ne 'en' ){
    $reslt_literalident = $self->render_to_string(
    template => $literalident_pkg_template,
    site_lang => $site_lang
    );
    $self->spurt( trim( encode('utf8', $reslt_literalident) ), $literalident_package_file);
}

$self->spurt( trim( encode('utf8', $reslt_transliter) ), $transliter_package_file);
$self->redirect_to('local_transliter');
}#*************

eval{
$exist_local_transliter_code = decode( 'utf8', $self->slurp( $local_transliter_file ) );
$package_code = decode( 'utf8', $self->slurp( $transliter_package_file ) );
$site_lang = decode( 'utf8', $self->slurp( $lang_file ) );
};

$self->render(
language => $language,
lng_codes => $self->top_config->{'langs'},
site_lang => $site_lang,
exist_local_transliter_code => $exist_local_transliter_code,
reslt => $reslt_transliter,
package_code => $package_code,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'transliteration'}->{$language},
head => $self->lang_config->{'transliteration_code'}->{$language},
);
}#-------------

#---------------------------
sub copy_files_newlang {
#---------------------------
my($self, $en_collection, $site_lang) = @_;
foreach my $item_en( @$en_collection ){
    my $item = $item_en;
    $item =~ s/\/en\//\/$site_lang\//;
    $item =~ s/\\en\\/\\$site_lang\\/;
    $item_en->copy_to( $item );
}    
}#-------------

#---------------------------
sub routines_list {
#---------------------------
my $self = shift;
my $language = $self->language;
my $template = $self->template;
my $routines_file = $self->top_config->{'routines_file'};
my $work_routine_file = 'conf/work_routine';
my $sitemap_templ_file = $self->top_config->{'sitemap_templ_file'};
my @levels_array = sort @{$self->top_config->{'levels'}};

#*****************************
if($self->param('routine')){
#*****************************
my $promise = Mojo::Promise->new;
$self->spurt($self->param('routine'), $work_routine_file);
    
my($menu_form, $menu, $sitemap) = $self->menu->save_menu( $self, time() );
my $new = $promise->resolve( ($menu_form, $menu, $sitemap) );

$promise->then(sub {
  $self->spurt(encode('utf8', $sitemap), $self->top_config->{'sitemap_templ_file'});
  $self->routine_model->menu_rewrite( $self, $menu, [@levels_array], time() );  
})->catch(sub {
  my $err = shift;
  $self->reply->exception($err);
})->wait;
  
$self->redirect_to( $self->url_for('/menu_manage')->query( time => time()) );
}#***********

my $routines = [split(/\|/, $self->slurp($routines_file))];
my $active_routine = $self->slurp($work_routine_file);

$self->render(
language => $language,
routines => $routines,
active_routine => $active_routine,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'routines'}->{$language},
head => $self->lang_config->{'routines'}->{$language},
);
}#-------------
1;