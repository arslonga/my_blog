package FileName;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------------
sub image_file {
#---------------------------------
my($self, $uploaded_filename) = @_;
my @pass_chars_rand = ("a".."z", "A".."Z", 0..9);
my $randomise = join("", @pass_chars_rand[map {rand @pass_chars_rand}(1..10)]);

return $randomise.'.jpg';
}#--------

#---------------------------------
sub doc_media_file {
#---------------------------------
my($self, $uploaded_filename) = @_;
my @pass_chars_rand = ("a".."z", "A".."Z", 0..9);
my $randomise = join("", @pass_chars_rand[map {rand @pass_chars_rand}(1..10)]);

$uploaded_filename =~ /.*\.(\w+)$/;
return $randomise.'.'.$1;
}#--------
1;