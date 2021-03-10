package Captcha;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(md5_sum);
use Cwd;
use Image::Magick;
my $cwd = cwd();

use strict;
use warnings;

my(@pass_chars, @pass_chars_password, $kol_digit, $passw_digit);

$kol_digit = 5;
$passw_digit = 7;
@pass_chars = (0..9);
@pass_chars_password = ("A".."Z", "a".."z", 0..9);

# Image options
my $img_width = 96;
my $img_height = 40;
my $fontsize = 28;
my $noise_pixels = 1000;

my $time_flag_live = 5*60;
my $time_flag_registrat = 60*60;
my $time_flag_reset_passw = 60*60;

#------------------------------------
sub check_anti_robot {
#------------------------------------
my($c, $self, $passstr, $sess_code) = @_;
my($check_pass, $mesg, $sess_file_content);

my $tempdir = $self->top_config->{'captcha_temp'};
 
 if (-e $cwd."/$tempdir/$sess_code.anti_robot"){

$check_pass = $self->slurp( $cwd.'/'.
                            $self->top_config->{'captcha_temp'}.'/'.
                            $sess_code.'.anti_robot' );

    if ($passstr == $check_pass){ 
        goto L1; 
    }else{
        return $self->lang_config->{alert}->{$self->language}->{veryftext_wrong};
    }
 }else{
    return $self->lang_config->{alert}->{$self->language}->{session_timeout};
 }

L1:
return ''; 
}#------------

#-------------------------------------------
sub check_register_data{
#-------------------------------------------
my($c, $self) = @_;
my $registr_data;
my $tempdir = $self->top_config->{'registr_temp'};
my $session_registr = $self->param('regid');
$c->del_old_session($self, 'registr_temp', $time_flag_registrat);
 
if (-e "$tempdir/$session_registr.registr"){
    $registr_data = $self->slurp( $cwd.'/'.$tempdir.'/'.$session_registr.'.registr' );
return $registr_data;
}#else{
return 'session_timeout';
#}
}#-------------

#-------------------------------------------
sub check_reset_data{
#-------------------------------------------
my($c, $self) = @_;
my $reset_data;
my $tempdir = $self->top_config->{'reset_temp'};
my $session_reset = $self->param('session');
$c->del_old_session($self, 'reset_temp', $time_flag_reset_passw);
 
if (-e "$tempdir/$session_reset.resetpassw"){
    $reset_data = $self->slurp( $cwd.'/'.$tempdir.'/'.$session_reset.'.resetpassw' );
return $reset_data;
}
return 'session_timeout';
}#-------------

#-------------------------------------------------
sub anti_new_session{
#-------------------------------------------------
my($c, $self) = @_;
 
my $new_pass_str = $c->get_pass_str();
my $new_session_code = $c->enctypt_session_code();

$c->del_old_session($self, 'captcha_temp', $time_flag_live);
$self->spurt( $new_pass_str, 
              $cwd.'/'.$self->top_config->{'captcha_temp'}.'/'.
              $new_session_code.'.anti_robot');

return ($new_pass_str, $new_session_code);
}#-------------

#-------------------------------------------------
sub anti_new_session_reg{
#-------------------------------------------------
my($c, $self, $session_code, $pass_str) = @_;

$c->del_old_session($self, 'registr_temp', $time_flag_registrat);
 
$self->spurt( $pass_str, 
              $cwd.'/'.$self->top_config->{'registr_temp'}.'/'.$session_code.'.registr');
}#-------------

#-------------------------------------------------
sub anti_new_session_reset_passw{
#-------------------------------------------------
my($c, $self, $session_code, $pass_str) = @_;

$c->del_old_session($self, 'reset_temp', $time_flag_reset_passw);
 
$self->spurt( $pass_str, 
              $cwd.'/'.$self->top_config->{'reset_temp'}.'/'.$session_code.'.resetpassw');
}#-------------
 
#------------------------------------
sub get_pass_str{
#------------------------------------
 srand();
 return join("", @pass_chars[map {rand @pass_chars}(1..$kol_digit)]);
}#----------

#--------------------------------------
sub enctypt_session_code{ 
#--------------------------------------
return md5_sum( time().$$ );
}#-----------

#-----------------------------------
sub del_old_session{
#-----------------------------------
my($c, $self, $key, $time_live) = @_;
my $mtime;

my $path = $self->path( $self->top_config->{$key} );

foreach my $f( $path->list->each ){
    $mtime = ( stat($f) )[9];
    if ( $mtime < time() - $time_live ){ 
        unlink( $f ) || die "$!"; 
    }
}
}#-------------

#-------------------------------------------
sub create_post_for_verif{
#-------------------------------------------
my($c, $self, $login, $session_code) = @_;
my $from = $self->top_config->{'noreply_mail'};
my $subject = 'Registration';
my $body = $self->lang_config->{msg_registr}->{$self->language}->{one}
.'<b>'.$login.'</b>.'."\n\n".$self->lang_config->{msg_registr}->{$self->language}->{two}
.' '.$self->req->headers->host.$self->lang_config->{msg_registr}->{$self->language}->{three}
.'<a style="background-color:#E7E7E7; padding:4px; display:inline-block; border: 1px solid gray" href="'
.$self->protocol.'://'.$self->req->headers->host.'/registration?regid='.$session_code
.'&msg=1&redirect_to='.$self->param('redirect_to').'">'
.$self->lang_config->{msg_registr}->{$self->language}->{four}."\n";

return ($from, $subject, $body);
}#--------------

# Пароль для користувача
#--------------------------------------
sub create_password{ 
#--------------------------------------
srand();
return join("", @pass_chars_password[map {rand @pass_chars_password}(1..$passw_digit)]);
}#-----------

#----------------------------------------
sub captcha{
#----------------------------------------
my($c, $self, $pass_str, $session_code) = @_;
my $sess_file_content;

if  ($session_code and -e $cwd.'/'.$self->top_config->{'captcha_temp'}.'/'.$session_code.'.anti_robot'){
    $pass_str.=$self->slurp( $cwd.'/'.$self->top_config->{'captcha_temp'}.'/'.$session_code.'.anti_robot' );;
}
else { 
    $self->redirect_to('/registration'); 
}

my $filepass = $cwd.'/'.$self->top_config->{'captcha_temp'}.'/'.$session_code.'.jpg';

# Нова картинка
my $image = Image::Magick->new;
   $image -> Set(
                 size => $img_width."x".$img_height,
                 magick => 'jpg'               
                );
 $image -> ReadImage('xc:white');

# Display the password with text distortion  
 my $step_x = 19;
 my $base_x = 5;
 my $base_y = $img_height - 5;

 foreach my $letter (split(//, $pass_str)){

  my $sdvig_x = int(rand(4))-2;
  my $sdvig_y = int(rand(10))-5;
  my $rotate  = int(rand(60))-30;

  $image->Annotate(
                   antialias => 'true',
                   pointsize => $fontsize,
                   x => $base_x+$sdvig_x,
                   y => $base_y+$sdvig_y,
                   rotate => $rotate,
                   fill	=> '#696969',
                   text	=> $letter
                  );

  $base_x+=$step_x;
 }

$image->AddNoise( noise => 'Gaussian', channel => 'blue' );
 
 for my $i (1..$noise_pixels){

  my $rnd_x = int(rand($img_width));
  my $rnd_y = int(rand($img_height));
  $image -> Set("pixel[$rnd_x,$rnd_y]" => "blue");

 }

  $image->Swirl( degrees => 20 );

  $image->Border(
                 width => '1',
                 height => '1',
                 bordercolor => 'gray'
                 );

  $image->Write(
                filename => $filepass, 
                quality=>75
               );

return $session_code.'.jpg';
}#-----------

1;