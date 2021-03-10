package MyBlog::Mail;
use Mojo::Base 'Mojolicious::Controller';
use MIME::Lite;

#--------------------------------------
sub just_text {
#--------------------------------------
my($self, $from, $to, $cc, $subject, $passw, $body) = @_;

    my $msg = MIME::Lite->new(
        From    => $from,
        To      => $to,
#        Cc      => $cc,
        Subject => $subject,
        Type     => 'TEXT',
        #Encoding => '7bit',
        Data    => $body
    );

#say "\n===================================\n$from\n$to\n$cc\n$subject\n$body<br>\n";
#exit;
eval{
$msg->send();
};

return 1;
}#----------

#--------------------------------------
sub as_html {
#--------------------------------------
my($self, $from, $to, $cc, $subject, $body) = @_;

### Create the multipart "container":
    my $msg = MIME::Lite->new(
        From    =>$from,
        To      =>$to,
#        Cc      =>$cc,
        Subject =>$subject,
        Type    =>'multipart/mixed'
    );
    
   ### Add the html content
    $msg->attach(
        Type => 'text/html',
        Data => qq{
            <body>
			$body
            </body>
        }
    );

#print "Content-Type: text/html; charset=cp1251\n\n";
#print "<br>===================================<br>\n$from<br>\n$to<br>\n$cc<br>\n$subject<br>\n$body<br>\n";
#exit;
eval{
  $msg->send();
};

return 1;
}#----------

#--------------------------------------
sub sending_mail {
#--------------------------------------
my($from, $to, $cc, $subject, $body, $pdf_file, $file_path) = @_;

### Create the multipart "container":
    my $msg = MIME::Lite->new(
        From    =>$from,
        To      =>$to,
        Cc      =>$cc,
        Subject =>$subject,
        Type    =>'multipart/mixed'
    );
	
#	    $msg->attach(
#        Type     =>'TEXT',
#        Data     =>"Caoa caiiaeaiiy o PDF oaee?!!!"
#    );

    ### Add the pdf part:
    $msg->attach(
        Type        => 'application/pdf',
        Path        => $file_path,
        Filename    => $pdf_file,
        Disposition => 'attachment'
    );
    
   ### Add the html content
    $msg->attach(
        Type => 'text/html',
        Data => qq{
            <body>
			$body
            </body>
        },
    );

#print "Content-Type: text/html; charset=cp1251\n\n";
#print "<br>===================================<br>\n$from<br>\n$to<br>\n$cc<br>\n$subject<br>\n$body<br>\n";
#exit;
eval{
  $msg->send();
};

return 1;
}#----------
1;
