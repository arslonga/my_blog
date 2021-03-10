package CommentClean;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim);

#-------------------------------------
sub clean_comment {
#-------------------------------------
my($self, $c, $response_data) = @_;

$response_data =~ s/[\W]+$//g if($response_data =~ /\W{20,}$/ && $response_data =~ /\D{20,}$/); 

while( $response_data =~ /(<.*a\W*)([^<>]*)(http[^\"\']*|https[^\"\']*)([^<]*>)([^<>]*)(<.*\/\W*a.*>)/i){
    $response_data =~ s/(<.*a\W*)([^<>]*)(http[^+\"\']*|https[^\"\']*)([^<]*>)([^<>]*)(<.*\/\W*a.*>)/$3 $5/gi;
}
if( $response_data =~ /<.*img[^<>]*>/i ){
    $response_data =~ s/<.*img[^<>]*>//g;
}

$response_data =~ s/<.*>//g if( $response_data =~ /<.*>/ );

$response_data =~ s/\[\s*code\s*\]/<code>/g if( $response_data =~ /\[\s*code\s*\]/ );
$response_data =~ s/\[\s*\/\s*code\s*\]/<\/code>/g if( $response_data =~ /\[\s*\/\s*code\s*\]/ );

if( $response_data =~ /<code>/i &&  !( $response_data =~ /<\/code>/i ) ){
    $response_data =~ s/<[^<>]*>//g;
}

$response_data =~ s/\W//g if($response_data =~ /^\W{20,}$/);
$response_data =~ s/\_//g if($response_data =~ /\_{3,}/); 
$response_data =~ s/\W//g if($response_data =~ /^\W{20,}$/);  
$response_data =~ s/[\W]+$//g if($response_data =~ /\W{20,}$/ && $response_data =~ /\D{20,}$/);

$response_data =~ s/\<br\>//ig if($response_data =~ /\<br\>/);
$response_data =~ s/[\n]/<br>/g if($response_data =~ /[\n]/);
if( $response_data =~ /<code>\W*<br>/ ){
    $response_data =~ s/<code>\W*<br>/<code>/g;
}
return $response_data;
}#---------------

#-------------------------------------
sub clean_edited {
#-------------------------------------
my($self, $c, $response_data) = @_;

$response_data =~ s/[\W]+$//g if($response_data =~ /\W{20,}$/ && $response_data =~ /\D{20,}$/);   
            
while( $response_data =~ /(<.*a\W*)([^<>]*)(http[^\"\']*|https[^\"\']*)([^<]*>)([^<>]*)(<.*\/\W*a.*>)/i ){
    $response_data =~ s/(<.*a\W*)([^<>]*)(http[^+\"\']*|https[^\"\']*)([^<]*>)([^<>]*)(<.*\/\W*a.*>)/$3 $5/gi;
}
if( $response_data =~ /<.*img[^<>]*>/i ){
    $response_data =~ s/<.*img[^<>]*>//g;
}
$response_data =~ s/<\s*code\s*>/\[code\]/g if( $response_data =~ /<\s*code\s*>/ );
$response_data =~ s/<\s*\/\s*code\s*>/\[\/code\]/g if( $response_data =~ /<\s*\/\s*code\s*>/ );

$response_data =~ s/<.*>//g if( $response_data =~ /<.*>/ );

$response_data =~ s/\[\s*code\s*\]/<code>/g if( $response_data =~ /\[\s*code\s*\]/ );
$response_data =~ s/\[\s*\/\s*code\s*\]/<\/code>/g if( $response_data =~ /\[\s*\/\s*code\s*\]/ );


if( $response_data =~ /<code>/i &&  !( $response_data =~ /<\/code>/i ) ){
    $response_data =~ s/<[^<>]*>//g;
}

$response_data =~ s/\W//g if($response_data =~ /^\W{20,}$/);
$response_data =~ s/\_//g if($response_data =~ /\_{3,}/); 
$response_data =~ s/\W//g if($response_data =~ /^\W{20,}$/);  
$response_data =~ s/[\W]+$//g if($response_data =~ /\W{20,}$/ && $response_data =~ /\D{20,}$/);   
            
$response_data =~ s/\<br\>//ig if($response_data =~ /\<br\>/);
$response_data =~ s/[\n]/<br>/g if($response_data =~ /[\n]/);
return $response_data;
}#---------------

#-------------------------------------
sub sbstr {
#-------------------------------------
my($self, $c) = @_;
return trim(substr($c->param('response'), 0, 3000));
}#---------------

#-------------------------------------
sub sbstr_edit {
#-------------------------------------
my($self, $c) = @_;            
return trim(substr($c->param('edit_answ'), 0, 3000));
}#---------------

#-------------------------------------
sub sbstr_answ {
#-------------------------------------
my($self, $c) = @_;            
return trim(substr($c->param('answer'), 0, 3000));
}#---------------
1;