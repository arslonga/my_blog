package ArticleProper;
use Mojo::Base 'Mojolicious::Controller';

#----------------------------------------------
sub new{
#----------------------------------------------
   my $proto = shift;
   my $class = ref($proto) || $proto;

   my $self = {};

   bless($self, $class);
return $self;
}#-------------

#---------------------------
sub article_proper {
#---------------------------
my $self = shift;
my($c, $type);

if(@_){ ($c, $type) = @_; }

$self = {
                     'index' => sub{
                                      my($level, $url_chaptr);
                                      my $url = $c->req->url;
                                      if(scalar( split(/\//, $url) ) == 3){
                                        $level = $c->top_config->{'rel_numb_items_of_address'}->{3};
                                        $url_chaptr = '/'.(split(/\//, $url))[1].'/'.(split(/\//, $url))[2];
                                        return {'table' => $level, 'url_chaptr' => $url_chaptr, 'bread_crumbs' => 'yes'};
                                      }
                                      return {'table' => $c->top_config->{'rel_numb_items_of_address'}->{scalar(split(/\//, $url))}, 'url_chaptr' => '', 'bread_crumbs' => ''};  
                                     },
                                     
                     'article' => sub{
                                      my $url = $c->req->url;
                                      my $table = $c->top_config->{'rel_numb_items_of_address'}->{2};
                                      my $id = (split(/\//, $url))[-2];
                                      my $url_chaptr = '/'.(split(/\//, $url))[1];
                                      return {'table' => $table, 'id' => $id, 'url_chaptr' => $url_chaptr, 'bread_crumbs' => ''};  
                                      #return {'table' => $table, 'id' => $id, 'url_chaptr' => $url_chaptr, 'bread_crumbs' => 'yes'};  
                                     },
                                     
                'article_sub' => sub{
                                      my $url = $c->req->url;
                                      my $table = $c->top_config->{'rel_numb_items_of_address'}->{3};
                                      my $id = (split(/\//, $url))[-2];
                                      my $url_chaptr = '/'.(split(/\//, $url))[1].'/'.(split(/\//, $url))[2];
                                      return {'table' => $table, 'id' => $id, 'url_chaptr' => $url_chaptr, 'bread_crumbs' => 'yes'};  
                                     }

};

return $self->{$type}->();
}#-------------
1;