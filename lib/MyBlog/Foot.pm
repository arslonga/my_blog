package MyBlog::Foot;
use Mojo::Base 'Mojolicious::Controller';
use Mojo::Util qw(encode decode);

#---------------------------
sub foot {
#---------------------------
my $self = shift;
my $language = $self->language;
my $foot_file = $self->top_config->{'foot_file'};

if($self->param('foot_content')){
    $self->spurt(encode('utf8', $self->param('foot_content')), $foot_file);
}
my $foot_code = decode('utf8', $self->slurp($foot_file));

$self->render(
language => $language,
foot_code => $foot_code,
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'},
title => $self->lang_config->{'foot'}->{$language},
head => $self->lang_config->{'foot'}->{$language},
);
}#-------------
1;