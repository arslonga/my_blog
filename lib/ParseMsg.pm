package ParseMsg;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim decode);

#---------------------------------
sub msg_registr {
#---------------------------------
my($self, $c, $file, $login, $password) = @_;

my $language = $c->language;
my $template = $c->template;
my $msg_format_file = 'conf/'.$language.'/'.$file;

my $data = $c->slurp($msg_format_file);
my $site = $c->protocol.'://'.$c->req->headers->host;

$data =~ s/\[login\]/$login/;
$data =~ s/\[password\]/$password/;
$data =~ s/\[site\]/$site/;

return $data;
}#---------------

#---------------------------------
sub msg_change_profile {
#---------------------------------
my($self, $c, $file, $login, $password) = @_;

my $language = $c->language;
my $template = $c->template;
my $msg_format_file = 'conf/'.$language.'/'.$file;

my $data = $c->slurp($msg_format_file);

my $site = $c->protocol.'://'.$c->req->headers->host;
$data =~ s/\[login\]/$login/;
if( $data =~ /\[password\]/ ){
    $data =~ s/\[password\]/$password/;
}
$data =~ s/\[site\]/$site/;

return $data;
}#---------------

#---------------------------------
sub msg_newsletter {
#---------------------------------
my($self, $c, $file, $login, $password) = @_;

my $language = $c->language;
my $template = $c->template;
my $msg_format_file = 'conf/'.$language.'/'.$file;

my $data = $c->slurp($msg_format_file);
my $site = $c->protocol.'://'.$c->req->headers->host;
$data =~ s/\[login\]/$login/;
$data =~ s/\[site\]/$site/;

return $data;
}#---------------

#---------------------------------
sub msg_newsletter_add {
#---------------------------------
my($self, $c, $file) = @_;

my $language = $c->language;
my $template = $c->template;
my $msg_format_file = 'conf/'.$language.'/'.$file;

my $data = $c->slurp($msg_format_file);

my $site = $c->protocol.'://'.$c->req->headers->host;
$data =~ s/\[site\]/$site/;

return $data;
}#---------------

#---------------------------------
sub msg_forgot_passw {
#---------------------------------
my($self, $c, $file, $login, $session_code) = @_;

my $language = $c->language;
my $template = $c->template;
my $msg_format_file = 'conf/'.$language.'/'.$file;

my $data = $c->slurp($msg_format_file);
my $site = $c->protocol.'://'.$c->req->headers->host;

$data =~ s/\[login\]/\<b\>$login\<\/b\>/;
$data =~ s/\[site\]/$site/;
$data.='<a style="background-color:#E7E7E7; padding:4px; display:inline-block; border: 1px solid gray" href="'
.$c->protocol.'://'.$c->req->headers->host.$c->req->url.'?session='.$session_code.'&option=reset">';
$data.=$c->lang_config->{'reset_password'}->{$language}.'</a>'."\n";

return $data;
}#---------------

#---------------------------------
sub msg_about_response {
#---------------------------------
my($self, $c, $file, $parent_user, $login, $parent_id, $id) = @_;

my $msg_format_file = 'conf/'.$c->language.'/'.$file;
my $table_comments = $c->top_config->{'table'}->{'comments'};
my $comment_prefix  = $c->top_config->{'comment_prefix'};

my $data = decode('utf8', $c->slurp($msg_format_file));

my($parent_url, $parent_comment) = $c->menu->find( $table_comments, 
                                                   ['url', 'comment'], 
                                                   {'id' => $parent_id})->list;
my($url, $comment) = $c->menu->find( $table_comments, 
                                     ['url', 'comment'], 
                                     {
                                      'nickname' => $login, 
                                      'parent_id' => $parent_id, 
                                      'id' => $id
                                     })->list;
my $parent_link = $c->protocol.'://'.
$c->req->url->to_abs->host.$parent_url.'#'.$comment_prefix.$parent_id;
my $link = $c->protocol.'://'.
$c->req->url->to_abs->host.$url.'#'.$comment_prefix.$id;

my $exchang1=<<HTML;
<div>
<b>$parent_user</b><br>
<a href="$parent_link">$parent_comment</a>
</div>
<br>
HTML

my $exchang2=<<HTML;
<div style="margin-left:30px">
<b>$login</b><br>
<a href="$link">$comment</a>
</div>
<br>
HTML

$data =~ s/\[parent_resp\]/$exchang1/;
$data =~ s/\[response\]/$exchang2/;

return $data;
}#---------------
1;