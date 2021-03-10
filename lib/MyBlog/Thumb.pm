package MyBlog::Thumb;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------------
sub thumb_img {
#---------------------------------
my $self = shift;

my $language = $self->language;
my $thumb_img_style_file = $self->top_config->{'thumb_img_style_file'};

my $table = $self->param('title_alias');
my $id    = $self->param('id');

my($level, $level_id, $head) = $self->menu->find( $table, 
                                                  ['level', 'level_id', 'head'], 
                                                  {id => $id})->list;
my $list_of_styles = $self->top_config->{'thumb_img'};

if( $self->param('set_style') ){
    $self->spurt( $self->param('thumb_img_style'), $thumb_img_style_file );
}

my $style = $self->slurp($thumb_img_style_file);
say $self->lang_config->{'miniature_style'}->{$language};
say $self->lang_config->{labels}->{$language}->{masterroom};

$self->render(
language => $language,
title_alias => $table,
head => $head,
id => $id,
exist_style => $style,
styles_list => $list_of_styles,
title => $self->lang_config->{'miniature_style'}->{$language}
);
}#------------
1;