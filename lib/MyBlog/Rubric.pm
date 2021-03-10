package MyBlog::Rubric;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(trim encode decode);
use EveryParam;

#---------------------------------
sub add_rubric {
#---------------------------------
my $self = shift;

my(@rubric_list, $message, %exist, %id_name_rubric, @rubrics);
my $language = $self->language;
my $user_id = $self->session('client')->[0] if($self->session('client'));
my $table_rubric = $self->top_config->{'table'}->{'rubric'};

my $table = $self->param('title_alias');
my $id    = $self->param('id');
my($level, $level_id, $head) = $self->menu->find( $table, 
                                                  ['level', 'level_id', 'head'], 
                                                  {id => $id}
                                                )->list;

#*******************************************************    
if( $self->param('add_rubric') ){
#*******************************************************
my $v = $self-> _validation( $self->top_config->{'add_rubric_required_fields'} );
    goto EN if $v->has_error;
    
    my $rubric = $self->regexp->title_clean( trim($self->param('rubric')) );    
    my $indicr  = $self->menu->find( $table_rubric, 
                                     ['rubric'], 
                                     { rubric => $rubric } 
                                   )->list;

    if($indicr){
        $message = "<b style=\"color:red\">".
        $self->lang_config->{'alert'}->{$language}->{'rubric_exist'}."</b>\n";
        goto EN;
    }    
    $self->menu->create( $table_rubric, {rubric => "$rubric"} );
}#**********

EN:
my $result = $self->db_table->rubrics( $self, $table_rubric );
    foreach my $rubr_item(@$result){
        push @rubric_list, $rubr_item;
    }
    
my @title_alias = @{TitleAliasList->title_alias_list($self)};

$self->render(
client => $self->session('client'),
language => $language,
message => $message,
title_alias => $table,
head => $head,
id => $id,
rubric_list => [@rubric_list],
redirect_to => $self->param('redirect_to'),
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'labels'}->{$language}->{'add_rubric'}
);
}#------------

#---------------------------------
sub edit_rubric {
#---------------------------------
my $self = shift;

my( %modif_cat_hash, @rubric_list, @edit_rubric_required_fields, 
    $edit_rubric_required_fields, $message, @rubrics);
my $language = $self->language;
my $table_rubric = $self->top_config->{'table'}->{'rubric'};
my $table = $self->param('title_alias');
my $id    = $self->param('id');
my($level, $level_id, $head) = $self->menu->find( $table, 
                                                  ['level', 'level_id', 'head'], 
                                                  {id => $id} 
                                                )->list;

my $rubric_ref = $self->menu->find( $table_rubric, ['*'], {}, 'id' )->hashes;
foreach(@$rubric_ref){
    push @edit_rubric_required_fields, 'rubric_'."$_->{'id'}";
}
$edit_rubric_required_fields = [@edit_rubric_required_fields];

foreach my $item( @$rubric_ref ){
    $modif_cat_hash{$$item{rubric}} = $item;
}
#**********************************    
if( $self->param('edit_rubric') ){
#********************************** 

my $v = $self-> _validation( $edit_rubric_required_fields );
    goto EC if $v->has_error;
    
    foreach( EveryParam->get_param_names($self) ){
        if($_ =~ /^rubric_/){
            push @rubrics, 
            (split(/\_/, $_))[-1].'|'.
            $self->regexp->title_clean( trim($self->param($_)) );
        }
    }

foreach(@rubrics){
    my($id_rubric, $val_rubric) = split(/\|/, $_);
    $self->menu->save( $table_rubric, 
                       {rubric => $val_rubric}, 
                       {id => $id_rubric} 
                     );
}

$self->redirect_to( $self->url_for('edit_rubric')->
                    query(
                          title_alias => $table,
                          id          => $id,
                          time        => time()
                         )
                  );
} #***********

EC:

$self->render(
client => $self->session('client'),
language => $language,
message => $message,
title_alias => $table,
head => $head,
id => $id,
modif_cat_hash => \%modif_cat_hash,
redirect_to => $self->param('redirect_to'),
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'labels'}->{$language}->{'edit_rubric'}
);
}#------------

#---------------------------
sub rubric_setting {
#---------------------------
my $self = shift;
my $language = $self->language;
my $list_of_rubric_numbers = $self->top_config->{'rubric_list_size'};

if($self->param('rubric_list_size')){
    $self->spurt( $self->param('rubric_list_size'), 
                  $self->top_config->{'rubric_list_size_file'} 
                );
$self->redirect_to('rubric_setting');
}
my $exist_rubric_numbers = $self->slurp( $self->top_config->{'rubric_list_size_file'} );

$self->render(
language => $language,
list_of_rubric_numbers => $list_of_rubric_numbers,
exist_rubric_numbers => $exist_rubric_numbers,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'labels'}->{$language}->{'rubric_setting'},
head => $self->lang_config->{'labels'}->{$language}->{'rubric_setting'}
);
}#-------------
1;