package Mjsimple_v::MenuClient;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode);

#----------------------------------
sub menu{
#----------------------------------
my($self, $c, $ref_hash_dir_subs) = @_;
my %hash_dir_subs = %{$ref_hash_dir_subs};
my($menu_components, $sitemap);
my $dropdown_id_parretn = 'coLLapse';
my $host_href = $c->protocol.'://'.$c->req->headers->host;
my $action = 'decode_'.$c->db_driver;

my $select_attr = "";
foreach(@{$hash_dir_subs{NULL}}){#*****************
    $_->{title} = $c->$action( $_->{title} );
    my $title = $_->{title};
    my $Url = $_->{url};

if($_->{subs} ){
    next if($_->{'in_menu'} eq 'no');
if( $_->{level} ne 'level0' ){

$menu_components.=<<MENU;
<div class="paNel-heading">
  <h4 class="paNel-title">
    <a class="collp" id="_coLLapse$_->{id}">
        $_->{title} <span id="$_->{id}" class="chevron right"></span>
    </a>
  </h4>
</div>
<div id="coLLapse$_->{id}" class="paNel-coLLapse coLLapse">
 <div class="paNel-body">
MENU

}
else{
$menu_components.=<<MENU;
<div class="paNel-heading" id="noAcc$_->{id}">
  <h4 class="paNel-title">
  <a href="$Url">$title</a>
  </h4>
</div>
MENU

}
my $menu_compnts = __PACKAGE__->select_including( $c, $_->{subs} );
$menu_components.=$menu_compnts;
}
else{    
$menu_components.=<<MENU;
<div class="paNel-heading">
  <h4 class="paNel-title">
    <a href="$Url">
	$title
    </a>
  </h4>
</div>
MENU

}

} # foreach **************

foreach(@{$hash_dir_subs{NULL}}){#*****************

    my $title = $_->{title};
    my $Url = $_->{url};

if($_->{subs} ){
    next if($_->{'in_menu'} eq 'no');
    
$sitemap.="<ul>\n";

    if( $_->{level} ne 'level0' ){
        $sitemap.="<li>\n".$_->{title}."</li>\n";
    }
    else{
        $sitemap.="<li><a href=\"$Url\">$title</a></li>\n";
}
my $site_map = __PACKAGE__->select_including_sitemap( $c, $_->{subs} );
$sitemap.=$site_map;
}
else{
  $sitemap.="<ul>\n<li><a href=\"$_->{url}\">$_->{title}</a></li>\n</ul>\n";
}

} # foreach **************

return($menu_components, $sitemap);
}#--------------

#----------------------------------------
sub select_including{
#----------------------------------------
my($self, $c, $ref_subs_content, $subs_indicator) = @_;
my($menu_subs_components);
my $dropdown_id_parretn = 'coLLapse';
my @subs_content = @$ref_subs_content;
my $action = 'decode_'.$c->db_driver;

foreach my $data(@subs_content){ #---------------
    $data->{title} = $c->$action( $data->{title} );
    my $title = $data->{title};
    my $Url = $data->{url};
    my $Url_mod = $Url; $Url_mod =~ s/\///g;

    next if($data->{'in_menu'} eq 'no');

if( $data->{subs} ){

$menu_subs_components.=<<MENU;
<div class="paNel-heading">
  <h4 class="paNel-title">
    <a class="collp" id="_coLLapse$data->{id}">
        $data->{title} <span id="$data->{id}" class="chevron right"></span>
    </a>
  </h4>
</div>
<div id="coLLapse$data->{id}" class="paNel-coLLapse coLLapse">
 <div class="paNel-body">
MENU

        my $menu_subs_compnts = __PACKAGE__->select_including( $c, $data->{subs}, 'yes');
		$menu_subs_components.=$menu_subs_compnts;
	}else{

if($subs_indicator){

$menu_subs_components.=<<MENU;
<div class="subchapt_style">
  <a href="$Url">$title</a>
</div>
MENU

}else{
$menu_subs_components.=<<MENU;
<div class="paNel-heading" id="noAcc$data->{id}">
  <h4 class="paNel-title">
  <a href="$Url">$title</a>
  </h4>
</div>
MENU

}

}
    
} # foreach ----------------------
if($subs_indicator){
    $menu_subs_components.="</div>\n</div>\n";
}
return $menu_subs_components;
}#-------------

#----------------------------------------
sub select_including_sitemap{
#----------------------------------------
my($self, $c, $ref_subs_content, $subs_indicator) = @_;
my($menu_subs_components, $sitemap);
my @subs_content = @$ref_subs_content;

foreach my $data(@subs_content){ #---------------

next if($data->{'in_menu'} eq 'no');

if( $data->{subs} ){
    $sitemap.="<li>\n".$data->{title}."</li>\n<ul>\n";

        my $site_map = __PACKAGE__->select_including_sitemap( $c, $data->{subs}, 'yes');
        $sitemap.=$site_map;
	}else{
        $sitemap.="<li><a href=\"$data->{url}\">$data->{title}</a></li>\n";
    }
    
} # foreach ----------------------

return $sitemap."</ul>\n";
}#-------------
1;