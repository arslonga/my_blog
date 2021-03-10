package RubricList;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(decode);

#------------------------------------
sub rubric_list {
#------------------------------------
my($self, $c) = @_;
my $language = $c->language;
my $table_rubric = $c->top_config->{'table'}->{'rubric'};
my $rubric_list_size = $c->slurp( $c->top_config->{'rubric_list_size_file'} ); 
my $no_rubric_name = $c->lang_config->{'no_rubric'}->{$language};
my(%exist, %id_name_rubric, %rubr_id_count, @rubrics, $cnt, $exist_rubr_numb);

my @title_alias = @{TitleAliasList->title_alias_list($c)};

# Спрочатку знаходимо ###############################
OVNER:
foreach my $curr_table( @title_alias ){
    my $result = $c->menu->find($curr_table, ['distinct(rubric_id)'])->flat;
    INNER:
    foreach my $rubric_id(@$result){
        next INNER if($exist{$rubric_id});
        $exist_rubr_numb++;
        $exist{$rubric_id} = 1;
    }
}
%exist = ();
################################

my $i = 1;
OVNER:
foreach my $curr_table(@title_alias){
    my $result = $c->menu->find($curr_table, ['distinct(rubric_id)'])->flat;
    INNER:
    foreach my $rubric_id(@$result){
        next INNER if($exist{$rubric_id});
        last OVNER if($i > $rubric_list_size);
        my $rubric_name = $c->menu->find( $table_rubric, 
                                          ['rubric'], 
                                          {'id' => "$rubric_id"}
                                        )->list;
        push @rubrics, $rubric_id;
        $id_name_rubric{$rubric_id} = $rubric_name;
        $exist{$rubric_id} = 1;
        $i++;
    }
}
%exist = ();

# Тут id рубрики - '0'
$id_name_rubric{'0'} = $no_rubric_name;

foreach my $rubric_id(keys %id_name_rubric){
    $cnt = 0;
    foreach my $curr_table(@title_alias){
    my $result = $c->menu->find( $curr_table, 
                                 ['id'], 
                                 {'rubric_id' => $rubric_id})->flat;
    foreach my $rubr_id(@$result){
        $cnt++ if $rubr_id;
    }
    }
$rubr_id_count{$rubric_id} = $cnt;
}

return(\%id_name_rubric, \%rubr_id_count, $exist_rubr_numb);
}#-------------

#--------------------------------------
sub show_rubrics {
#--------------------------------------
my $self = shift;

my $language = $self->language;
my $templ = lc($self->template).'/show_rubric';
my $table_rubric = $self->top_config->{'table'}->{'rubric'};
my $table_archive_menu = $self->top_config->{'table'}->{'archive_menu'};
my($message, $rubr_name, $db);
my $action = 'decode_'.$self->db_driver;

my $id = (split(/\//, $self->req->url))[-1];

my($description, $keywords) = $self->menu->find( 'level0', 
                                                 ['description', 'keywords'] 
                                               )->list;

my $menu = RewrMenu->active_rewrite( $self );
my $archive_menu = $self->menu->find( $table_archive_menu, 
                                      ['menu'], 
                                      {'url' => 'common'} )->list;
my( $ref_id_name_rubric, 
    $ref_rubr_id_count, 
    $exist_rubr_numb) = __PACKAGE__->rubric_list($self);

my $content = __PACKAGE__->get_content($self, $id);

my $title = $self->lang_config->{'rubric'}->{$language}.' "'.
$self->$action( $$ref_id_name_rubric{$id} ).'"';

$self->render(
template => $templ,
list_enable => '',
language => $language,
message => $message,
id => $$ref_id_name_rubric{$id}.' '.$id,
menu => $menu,
rubric => $$ref_id_name_rubric{$id} || 
$self->menu->find( $table_rubric, ['rubric'], {'id' => $id} )->list,
content => $content,
archive_menu => $archive_menu,
title => $title,
description => $title.'. '.$description,
keywords => $title.'. '.$keywords,
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb
);
}#--------------

#------------------------------------
sub show_all {
#------------------------------------
my($c) = @_;
my $language = $c->language;
my $templ = lc($c->template).'/all_rubrics';
my $table_archive_menu = $c->top_config->{'table'}->{'archive_menu'};
my $table_rubric = $c->top_config->{'table'}->{'rubric'};
my $rubric_list_size = $c->slurp( $c->top_config->{'rubric_list_size_file'} );
my $no_rubric_name = $c->lang_config->{'no_rubric'}->{$language};
my(%exist, %id_name_rubric, %rubr_id_count, @rubrics, $db, $message, $cnt);
my $title = $c->lang_config->{'all_rubrics'}->{$language};

my($description, $keywords) = $c->menu->find( 'level0', 
                                              ['description', 'keywords'] 
                                            )->list;
my @title_alias = @{TitleAliasList->title_alias_list($c)};

my $rubr_count = 1;
foreach my $curr_table(@title_alias){
    my $result = $c->menu->find( $curr_table, ['distinct(rubric_id)'] )->flat;
    foreach my $rubric_id(@$result){
        next if $exist{$rubric_id};
        my $rubric_name = $c->menu->find( $table_rubric, 
                                          ['rubric'], 
                                          {'id' => $rubric_id} )->list;
        push @rubrics, $rubric_id;
        $id_name_rubric{$rubric_id} = $rubric_name;
        $exist{$rubric_id} = 1;
    $rubr_count++ if $rubric_id;
    }
}

$id_name_rubric{'0'} = $no_rubric_name;

foreach my $rubric_id(keys %id_name_rubric){

    $cnt = 0;
    foreach my $curr_table(@title_alias){
    my $result = $c->menu->find( $curr_table, 
                                 ['id'], 
                                 {'rubric_id' => $rubric_id} 
                               );
    while(my $rubr_id = $result->list){
        $cnt++ if $rubr_id;
    }
    }
$rubr_id_count{$rubric_id} = $cnt;
}

my( $ref_id_name_rubric, 
    $ref_rubr_id_count, 
    $exist_rubr_numb) = __PACKAGE__->rubric_list($c);

my $menu = RewrMenu->active_rewrite( $c );
my $archive_menu = $c->menu->find( $table_archive_menu, 
                                   ['menu'], 
                                   {'url' => 'common'} )->list;

$c->render(
template => $templ,
language => $language,
list_enable => '',
message => $message,
menu => $menu,
archive_menu => $archive_menu,
title => $title,
description => $title.'. '.$description,
keywords => $title.'. '.$keywords,
rubr_count => $rubr_count,
rubrics_all => \%id_name_rubric,
number_for_rubric_all => \%rubr_id_count,
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb
);
}#-------------

#---------------------------------------
sub get_content{
#---------------------------------------
my($self, $c, $id) = @_;
my @title_alias = @{TitleAliasList->title_alias_list($c)};
my @content;

foreach my $curr_table(@title_alias){
    my $result = $c->menu->find( $curr_table, 
                                 ['id', 'level', 'curr_date', 'head', 'url', 'announce'],
                                 {
                                  'rubric_id' => $id
                                 } );
    while( my $data_ref = $result->hash ){
        $data_ref->{'url_chaptr'} = $data_ref->{'url'};
        push @content, $data_ref;
    }
}
return [@content];
}#-------------

#---------------------------------------
sub rubric_link {
#---------------------------------------
my($self, $c, $rubric_id) = @_;
my $language = $c->language;
my $table_rubric = $c->top_config->{'table'}->{'rubric'};

my $rubric_name = $c->menu->find( $table_rubric, ['rubric'], {'id' => $rubric_id} )->list;
my $rubric_link = "<a class=\"breadcr_href\" href=\"/rubric/$rubric_id\">$rubric_name</a>\n";

return $rubric_link;
}#-------------
1;