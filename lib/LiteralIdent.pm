package LiteralIdent;
use Mojo::Base 'Mojolicious::Controller';
use Transliter;

#---------------------------
sub literal_for_url {
#---------------------------
my($self, $c, $arg) = @_;

$arg = lc $arg;
$arg =~ s/\s+/\_/g;
$arg =~ s/[\W]+//g;

$self = {
    'uk' => sub{
                $arg = Transliter->transliter( $arg );
                $arg =~ s/[\W]+/\_/g; 
                $arg =~ s/\_/\-/g if($arg =~ /\_/);
                return $arg;
                },
    'en' => sub{
                $arg = Transliter->transliter( $arg );
                $arg =~ s/[\W]+/\_/g; 
                $arg =~ s/\_/\-/g if($arg =~ /\_/);
                return $arg;
                },
    'uk' => sub{
                $arg = Transliter->transliter( $arg );
                $arg =~ s/[\W]+/\_/g; 
                $arg =~ s/\_/\-/g if($arg =~ /\_/);
                return $arg;
                }
};

return $self->{$c->language}->();
}#-------------
1;