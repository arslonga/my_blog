package RewriteImage;
use Mojo::Base 'Mojolicious::Controller';
use Image::Magick;

#----------------------------------------------
sub new{
#----------------------------------------------
   my $proto = shift;
   my $class = ref($proto) || $proto;

   my $self = {};

   bless($self, $class);
return $self;
}#-------------

#-------------------------------------
sub illustration{
#-------------------------------------
my $self = shift;
my($c, $Directory, $uploaded_filename, $action);

if(@_){ ($c, $Directory, $uploaded_filename, $action) = @_; }

$self = {
         'resize' => sub{
                        my $image = new Image::Magick;
                        my($new_width, $new_height, $geom, $koef, $size);
                        my $x = $image->Read("$Directory/$uploaded_filename");
                        my ($o_width, $o_height) = $image->Get('width', 'height');
$o_width = $o_width - 2;
$o_height = $o_height - 2;
$geom = "${o_width}x$o_height";
$image->Crop(geometry => "$geom + 1 + 1");
$koef = $o_height/$o_width;

if($o_width > 600){$new_width = 600}else{$new_width = $o_width}
$new_height = $new_width * $koef;

$size = "${new_width}x$new_height";

my $Imag_resol = new Image::Magick;
$Imag_resol->Set(size => $size, 
                 density => '72x72',
                 #compression => 'JPEG'
                 compression => 'JPEG'
                 );
$Imag_resol->Read( 'xc:white' );
#$Imag_resol->Read( 'xc:transparent' );

$image->Thumbnail(width => $new_width, 
                  height => $new_height);

my $thumb = $image->Clone();

$Imag_resol->Composite(image => $thumb, 
                       interpolate => 'bicubic'
                       );

$Imag_resol->Write(filename => "$Directory/$uploaded_filename",
                    #quality => 75
                    quality => 75
                    );

my $n_width_ic = 60;
my $n_height_ic = int( $n_width_ic * $koef );

$image->Thumbnail(width => $n_width_ic, height => $n_height_ic);
my $thumb_ic = $image->Clone();

my $ic_file_nam='tn_'.$uploaded_filename;
$thumb_ic->Write(filename => "$Directory/$ic_file_nam", 
                 #quality => 75
                 quality => 75
                 );
                 
                        return;
                        },
#==================================                        
        'brand' => sub{
        
my $image = new Image::Magick;
my( $new_width, $new_height, $geom, $koef, $size );
my $x = $image->Read("$Directory/$uploaded_filename");
my($o_width, $o_height) = $image->Get('width', 'height');

$geom = "${o_width}x$o_height";
$image->Crop(geometry => "$geom + 1 + 1");
$koef = $o_height/$o_width;

$new_width = $c->top_config->{'brand_image_maxwidth'};
$new_height = $new_width * $koef;

$size = "${new_width}x$new_height";

$image->Thumbnail( width => $new_width, height => $new_height);
$image->Write( filename => $Directory.'/'.$uploaded_filename );
                 
return 1;
        },
#==================================
        'favicon' => sub{
        
my $image = new Image::Magick;
my( $new_width, $new_height, $geom, $koef, $size );
my $x = $image->Read("$Directory/$uploaded_filename");
my($o_width, $o_height) = $image->Get('width', 'height');

$geom = "${o_width}x$o_height";
$image->Crop(geometry => "$geom + 1 + 1");
$koef = $o_height/$o_width;

$new_width = $c->top_config->{'favicon_image_maxwidth'};
$new_height = $new_width * $koef;

$size = "${new_width}x$new_height";

$image->Thumbnail( width => $new_width, height => $new_height);
$image->Write( filename => $Directory.'/'.$uploaded_filename );
                 
return 1;
        }
                        
};        
        
return $self->{$action}->()
}#---------------

#-------------------------------------
sub lead_img{
#-------------------------------------
my $self = shift;
my($c, $Directory, $uploaded_filename);

if(@_){ ($c, $Directory, $uploaded_filename) = @_; }

my $image = new Image::Magick;
my($new_width, $new_height, $geom, $koef, $size);

my $x = $image->Read("$Directory/$uploaded_filename");
my ($width, $height) = $image->Get('width', 'height');
$koef = $height/$width;

my $width_lead = 200;
my $height_lead = int( $width_lead * $koef );

$image->Thumbnail(width => $width_lead, height => $height_lead);

my $lead_file_nam = 'lid_'.$uploaded_filename;
$image->Write(filename => "$Directory/$lead_file_nam", 
                 quality => 75);


return $lead_file_nam;
}#---------------

#-------------------------------------
sub logo_img{
#-------------------------------------
my $self = shift;
my($c, $Directory, $uploaded_filename, $new_width, $new_height, $geom, 
$koef, $koef_orig, $size, $imag1, $x);

if(@_){ ($c, $Directory, $uploaded_filename) = @_; }

my($h_need_logo, $w_need_logo) = @{$c->top_config->{'logo_img_geometry'}};

my $image = new Image::Magick;

$x = $image->Read("$Directory/$uploaded_filename");
my($width, $height) = $image->Get('width', 'height');
return("", "", "") if(!$width || !$height);
$koef_orig = $height/$width;

#************************************
if($width > $w_need_logo){
#************************************
    $imag1 = $image -> Clone();
    $new_height = $w_need_logo * $koef_orig;
    $imag1 -> Thumbnail(width => $w_need_logo, height => $w_need_logo * $koef_orig);
    if( $new_height > $h_need_logo ){
        my $vertical_step = ($new_height - $h_need_logo)/2;
        my $horiz_step    = 0;
        my $geometry = $w_need_logo.'x'.$h_need_logo.'+'.$horiz_step.'+'.$vertical_step;
        $imag1 -> Crop(geometry => $geometry);
        $new_height = $h_need_logo;
    }
    
}else{#********
    $imag1 = $image -> Clone();
    $new_width = $w_need_logo;
    $new_height = $new_width * $koef_orig;    
    $imag1 -> Resize(width => $new_width, height => $new_height);
    if( $new_height > $h_need_logo ){
        my $vertical_step = ($new_height - $h_need_logo)/2;
        my $horiz_step    = 0;
        my $geometry = $w_need_logo.'x'.$h_need_logo.'+'.$horiz_step.'+'.$vertical_step;
        $imag1 -> Crop(geometry => $geometry);
        $new_height = $h_need_logo;
    }
}#**************************
$x = $imag1->Write( filename => "$Directory/$uploaded_filename", 
                    quality => 100
                  );

return(1, $w_need_logo, $new_height);
}#---------------

#-------------------------------------
sub slide_img{
#-------------------------------------
my $self = shift;
my($c, $Directory, $uploaded_filename, $new_width, $new_height, $geom, 
$koef, $koef_orig, $size, $imag1, $x);

if(@_){ ($c, $Directory, $uploaded_filename) = @_; }

my($h_need_logo, $w_need_logo) = @{$c->top_config->{'logo_img_geometry'}};
$koef = $h_need_logo/$w_need_logo;

my $image = new Image::Magick;

$x = $image->Read("$Directory/$uploaded_filename");
my($width, $height) = $image->Get('width', 'height');
return("", "", "") if(!$width || !$height);
$koef_orig = $height/$width;

#************************************
if($width > $w_need_logo){
#************************************
    $imag1 = $image -> Clone();
    $new_height = $w_need_logo * $koef_orig;
    $imag1 -> Thumbnail(width => $w_need_logo, height => $w_need_logo * $koef_orig);
    if( $new_height > $h_need_logo ){
        my $vertical_step = ($new_height - $h_need_logo)/2;
        my $horiz_step    = 0;
        my $geometry = $w_need_logo.'x'.$h_need_logo.'+'.$horiz_step.'+'.$vertical_step;
        $imag1 -> Crop(geometry => $geometry);
        $new_height = $h_need_logo;
    }
    
}else{#********
    $imag1 = $image -> Clone();
    $new_width = $w_need_logo;
    $new_height = $new_width * $koef_orig;    
    $imag1 -> Resize(width => $new_width, height => $new_height);
    if( $new_height > $h_need_logo ){
        my $vertical_step = ($new_height - $h_need_logo)/2;
        my $horiz_step    = 0;
        my $geometry = $w_need_logo.'x'.$h_need_logo.'+'.$horiz_step.'+'.$vertical_step;
        $imag1 -> Crop(geometry => $geometry);
        $new_height = $h_need_logo;
    }
}#**************************
$x = $imag1->Write(filename => "$Directory/$uploaded_filename", 
                  quality => 100);

return(1, $w_need_logo, $new_height);
}#---------------
1;