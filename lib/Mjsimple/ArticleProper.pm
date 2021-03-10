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
my($c, $type, $list_enable);

if(@_){ ($c, $type, $list_enable) = @_; }

$self = {

'index' => sub{
               my($level, $url_chaptr);
               my $url = $c->req->url;
               if(scalar( split(/\//, $url) ) == 3){
                   $level = $c->top_config->{'rel_numb_items_of_address'}->{3};
                   $url_chaptr = '/'.(split(/\//, $url))[1].'/'.(split(/\//, $url))[2];
                   return {'table' => $level, 'url_chaptr' => $url_chaptr, 'bread_crumbs' => 'yes'};
               }
               return {'table' => $c->top_config->{'rel_numb_items_of_address'}->{scalar(split(/\//, $url))}, 
                       'url_chaptr' => '', 
                       'bread_crumbs' => 'yes'
                      };  
              },
                                     
'article' => sub{
                 my $url = $c->req->url;
                 my $table = $c->top_config->{'rel_numb_items_of_address'}->{2};
                 my $id = (split(/\//, $url))[-2];
                 my $url_chaptr = '/'.(split(/\//, $url))[1];
                 #return {'table' => $table, 'id' => $id, 'url_chaptr' => $url_chaptr, 'bread_crumbs' => ''};  
                 return {'table' => $table, 'id' => $id, 'url_chaptr' => $url_chaptr, 'bread_crumbs' => 'yes'};  
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

#---------------------------
sub bread_crumbs {
#---------------------------
my $self = shift;
my($c, $type, $table, $url_chaptr, $title, $list_enable) = @_;
my $action_decode = 'decode_'.$c->db_driver;

$self = {

'index' => sub{

my($bread_crumbs, $top_chapter);
my $top_level = 'level'.( substr($table, -1, 1) - 1 );
  if( (split(/\//, $url_chaptr))[1] ){
    $top_chapter = $c->menu->find( $top_level, 
                                   ['title'], 
                                   {'title_alias' => (split(/\//, $url_chaptr))[1]} 
                                 )->list;
    $top_chapter = $c->$action_decode( $top_chapter );
  }
$title = $c->$action_decode( $title );
if(!$top_chapter && $list_enable eq 'yes'){
$bread_crumbs=<<BRCR;
<ol class="breadcrumb" id="breadcrmb">
  <li class="active">$title</li>
</ol>
BRCR

}elsif( !$top_chapter && $list_enable eq 'no' ){
$bread_crumbs = '';
}else{
$bread_crumbs=<<BRCR;
<ol class="breadcrumb" id="breadcrmb">
  <li class="active">$top_chapter</li>
  <li class="active">$title</li>
</ol>
BRCR

}
return $bread_crumbs;
},
                                     
'article' => sub{

my($bread_crumbs, $top_chapter);    
my $top_level = 'level'.(substr($table, -1, 1) - 1);
$top_chapter = $c->menu->find( $top_level, 
                               ['title'], 
                               {'title_alias' => (split(/\//, $url_chaptr))[1]} 
                             )->list;
$top_chapter = $c->$action_decode( $top_chapter );
$title = $c->$action_decode( $title );    
if(!$top_chapter){
$bread_crumbs=<<BRCR;
<ol id="breadcrmb" style="margin-left: -30px">
  <li>
  <a href="$url_chaptr" class="breadcr_href">$title</a>
  </li>
</ol>
BRCR

}else{
$bread_crumbs=<<BRCR;
<ol class="breadcrumb" id="breadcrmb">
  <li class="active">$top_chapter</li>
  <li><a href="$url_chaptr" class="breadcr_href">$title</a>
  </li>
</ol>
BRCR

}
return $bread_crumbs;  
}
};

return $self->{$type}->();
}#-------------

1;