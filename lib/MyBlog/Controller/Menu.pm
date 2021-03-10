package MyBlog::Controller::Menu;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use MyBlog::MenuForm;

#---------------------------------
sub menu_manage {
#---------------------------------
my $self = shift;

my($menu_form, $menu, $message, $sitemap);
my $template = $self->template;
my $sitemap_templ_file = $self->top_config->{'sitemap_templ_file'};
my @levels_array = ();

#*********************************	
if( $self->param('edit') ){
#*********************************
my @levels = ();
    #*********************************
    if( $self->param('del_chapter') ){
    #*********************************
        my $max_level = ( sort @{$self->top_config->{'levels'}} )[-1];
        $self->routine->del_chapter($self, $max_level);   
    }#***************
    else{ #********** 
        my %data_hash = (title       => $self->regexp->title_clean( trim( lc($self->param('title')) ) ),
                         template    => $self->param('template'),
                         description => trim($self->param('description')),
                         keywords    => trim($self->param('keywords')),
                         queue       => $self->param('queue'),
                         in_menu     => $self->param('out_menu') || 'yes'
                        );
        my %where = (id => $self->param('id'));
        $self->menu->save($self->param('level'), \%data_hash, \%where);
    }#**********

$self->redirect_to('/menu_manage');		
}#*********** 

#***********************************
if( $self->param('add') ){
#***********************************
$message = $self->menu->correct_data_and_insert($self);
goto RENDRM if($message ne '');

#$self->redirect_to('/menu_manage');
}#************

($menu_form, $menu, $sitemap) = $self->menu->save_menu($self);

$self->spurt( encode('utf8', $sitemap), $self->top_config->{'sitemap_templ_file'} );
# Modify menu taking into account the style of the active sections
$self->routine_model->menu_rewrite( $self, $menu, [sort @{$self->top_config->{'levels'}}] );

RENDRM:
$self->render(
message  => $message,
menu => $menu,
sitemap => $sitemap,
menu_form => $menu_form,
title => $self->lang_config->{'labels'}->{$self->language}->{'menu'}
);
if($self->param('time')){
  $self->redirect_to('/menu_manage');
}
}#---------------

#---------------------------------
sub user_menu_manage {
#---------------------------------
my $self = shift;

my $table_users = $self->top_config->{'table'}->{'users'};
my(%title_alias_title);

my @edit_priority = split( /\|/, $self->menu->find( $table_users, 
                                                    ['edit_priority'], 
                                                    {'login' => $self->session('client')->[1]} 
                                                  )->list
                         );
foreach my $title_alias(@edit_priority){
    $title_alias_title{$title_alias} = 
    $self->menu->find( $self->menu->find( $title_alias, ['level'] )->list, 
                       ['title'], 
                       {'title_alias' => $title_alias}
                     )->list;
}

$self->render(
title_alias_title => {%title_alias_title},
title => $self->lang_config->{'labels'}->{$self->language}->{'menu'}
);
}#---------------
1;