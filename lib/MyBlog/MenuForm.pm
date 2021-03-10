package MyBlog::MenuForm;
use Mojo::Base 'Mojolicious::Controller';

#-----------------------------------------------
sub menu_tree {
#-----------------------------------------------
my($self, $c, $ref_hash_dir_subs) = @_;
my %hash_dir_subs = %{$ref_hash_dir_subs};
my $menu_form;

my $select_attr = "";
my $i = 1;
foreach(@{$hash_dir_subs{NULL}}){

####################################################################
    $menu_form.=$c->serve->get_menu_form( $c, $_, 'menu_block_'.$i );
####################################################################

if($_->{subs} ){
    $i++;
    my $menu_frm = $self->select_including( $c, $_->{subs}, $i );
    $menu_form.=$menu_frm;
}
$i++;
} # foreach ------
return $menu_form;
}#--------------

#----------------------------------------
sub select_including{
#----------------------------------------
my( $self, $c, $ref_subs_content, $i) = @_;
my($menu_form);
my @subs_content = @$ref_subs_content;

$i++;
foreach my $data(@subs_content){ #---------------

######################################################
    $menu_form.=$c->serve->get_menu_form( $c, $data, 'menu_block_'.$i );
###########################################################################
	if( $data->{subs} ){
        $i++;
        my $menu_frm = $self->select_including( $c, $data->{subs}, $i);
        $menu_form.=$menu_frm;
	}else{

    }
$i++;    
} # foreach ----------------------
return $menu_form;
}#-------------
1;