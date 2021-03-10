package Mjsimple::MenuClient;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw (encode decode);

#----------------------------------
sub menu{
#----------------------------------
my($self, $c, $ref_hash_dir_subs) = @_;
my %hash_dir_subs = %{$ref_hash_dir_subs};
my($sitemap, $dropdown_id);
my $brand_path = $c->top_config->{'brand_path'};
my $brand_image = $c->top_config->{'brand_image_name'};
my $dropdown_id_parretn = 'myDropdown';
my $host_href = $c->protocol.'://'.$c->req->headers->host;
my $action = 'decode_'.$c->db_driver;

my $menu_components=<<MENU;
<div class="containr">
<div class="nav_horbar" id="myTopnav">
<div class="item-left">
<a href="$host_href/">
<img src="/$brand_path/$brand_image" id="brand_style" border="0">
</a>
</div>
<div class="item-right">
<!--autrz-form-->
<span>
<a href="javascript:void(0);" class="icon" onclick="showNavig()">
    <span class="hambr-icon"></span>
    <span class="hambr-icon"></span>
    <span class="hambr-icon"></span>
</a>
</span>
</div>
<div class="menu">
  <div class="link-container">
MENU

my $select_attr = "";
my $i = 0;
foreach(@{$hash_dir_subs{NULL}}){#*****************
    $_->{title} = $c->$action( $_->{title} );

if($_->{subs} ){

next if($_->{'in_menu'} eq 'no');

        if( $_->{level} ne 'level0' ){
$i = $i + 1;
$dropdown_id = $dropdown_id_parretn.'_'.$i;
$menu_components.=<<MENU;
<div class="drop_down">
  <button class="dropbtn" onclick="showDropdown(\'$dropdown_id\')">$_->{title}
    <span class="down-caret">&#x25BC;</span>
  </button>
  <div class="dropdown-content" id="$dropdown_id">
MENU

        }
        else{
            $menu_components.="<a href=\"$_->{url}\">$_->{title}</a>\n";
        }
        my $menu_compnts = __PACKAGE__->select_including( $c, $_->{subs} );
		$menu_components.=$menu_compnts;
}else{
    $menu_components.="<a href=\"$_->{url}\">$_->{title}</a>\n</div>\n";
}

} # foreach **************

foreach(@{$hash_dir_subs{NULL}}){#*****************

    if($_->{subs} ){
        next if($_->{'in_menu'} eq 'no');
    
    $sitemap.="<ul>\n";

        if( $_->{level} ne 'level0' ){
        $sitemap.="<li>\n".$_->{title}."</li>\n";
        }
        else{
            $sitemap.="<li><a href=\"$_->{url}\">$_->{title}</a></li>\n";
        }
        my $site_map = __PACKAGE__->select_including_sitemap( $c, $_->{subs} );
        $sitemap.=$site_map;
    }else{
        $sitemap.="<ul>\n<li><a href=\"$_->{url}\">$_->{title}</a></li>\n</ul>\n";
    }

} # foreach **************
$menu_components.=<<MENU;
</div>
</div>
</div>
</div>
<!-------------------------------->
<div id="alternav">
$sitemap
</div>
MENU

return($menu_components, $sitemap);
}#--------------

#----------------------------------------
sub select_including{
#----------------------------------------
my($self, $c, $ref_subs_content) = @_;
my($menu_subs_components, $sitemap, $dropdown_id);
my @subs_content = @$ref_subs_content;
my $dropdown_id_parretn = 'myDropdown';
my $action = 'decode_'.$c->db_driver;

my $i = 0;
foreach my $data(@subs_content){ #---------------
  
  $data->{title} = $c->$action( $data->{title} );

  next if($data->{'in_menu'} eq 'no');

	if( $data->{subs} ){
$i = $i + 1;
$dropdown_id = $dropdown_id_parretn.'_'.$i;
$menu_subs_components.=<<MENU;
<div class="drop_down">
  <button class="dropbtn" onclick="showDropdown(\'$dropdown_id\')">$data->{title}
    <span class="down-caret">&#x25BC;</span>
  </button>
  <div class="dropdown-content" id="$dropdown_id">
MENU

        my $menu_subs_compnts = __PACKAGE__->select_including( $c, $data->{subs});
		$menu_subs_components.=$menu_subs_compnts."</div>\n";
	}else{
        $menu_subs_components.="<a href=\"$data->{url}\">$data->{title}</a>\n";
    }
    
} # foreach ----------------------

return $menu_subs_components."</div>\n";
}#-------------


#----------------------------------------
sub select_including_sitemap {
#----------------------------------------
my($self, $c, $ref_subs_content) = @_;
my($menu_subs_components, $sitemap);
my @subs_content = @$ref_subs_content;

foreach my $data(@subs_content){ #---------------

next if($data->{'in_menu'} eq 'no');

if( $data->{subs} ){
    $sitemap.="<li>\n".$data->{title}."</li>\n<ul>\n";
        my $site_map = __PACKAGE__->select_including_sitemap( $c, $data->{subs});
        $sitemap.=$site_map;
	}else{
        $sitemap.="<li><a href=\"$data->{url}\">$data->{title}</a></li>\n";
    }
    
} # foreach ----------------------

return $sitemap."</ul>";
}#-------------
1;