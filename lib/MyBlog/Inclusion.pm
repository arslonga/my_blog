package MyBlog::Inclusion;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------
sub inclusion {
#---------------------------
my $self = shift;
my $language = $self->language;
my $inclusion_kinds = $self->top_config->{'inclusion_kinds'};

$self->render(
language => $language,
content => $inclusion_kinds,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{inclusion}->{$language},
head => $self->lang_config->{inclusion}->{$language},
);
}#-------------

#---------------------------
sub inclusion_kind {
#---------------------------
use Mojo::Util qw(encode decode);
my $self = shift;
my $language = $self->language;
my $template = $self->template;
my $templ = lc($template).'/inclusion_kind';
my $inclusion_kind = $self->param('inclusion_kind');
my $inclusion_file = 'conf/'.$template.'/'.$inclusion_kind;
my($file, $inclusion_code);

#**************************
if($self->param('set_inclusion')){
#**************************
    $self->spurt( encode('utf8', $self->param('inclusion_code')), $inclusion_file );
}#*************

eval{
$inclusion_code = decode('utf8', $self->slurp($inclusion_file));
};

$self->render(
template => $templ,
language => $language,
inclusion_kind => $inclusion_kind,
inclusion_code => $inclusion_code,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{inclusion}->{$language},
head => $self->lang_config->{inclusion}->{$language},
);
}#-------------

#---------------------------
sub article_inclusion {
#---------------------------
my $self = shift;
my $language = $self->language;
my $id = $self->param('id');
my $title_alias = $self->param('title_alias');
my $title = $self->param('title');
my $redirect_to = $self->param('redirect_to');

#*****************************
if($self->param('inclusion')){
#*****************************
    $self->menu->save( $title_alias, {'inclusion' => $self->param('inclusion')}, {'id' => $id} );
}#********
my $inclusion = $self->menu->find( $title_alias, ['inclusion'], {'id' => $id} )->list;

$self->render(
language => $language,
title_alias => $title_alias,
article_title => $title,
id => $id,
chapter => $title,
content => $inclusion,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{inclusion}->{$language}.'. '.$title,
head => $self->lang_config->{inclusion}->{$language},
);
}#-------------
1;