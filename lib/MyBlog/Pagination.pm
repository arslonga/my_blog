package MyBlog::Pagination;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------
sub pgn_articl {
#---------------------------
my $self = shift;

if( $self->param('pgn_round') ){
    my $str_for_store = 'round:'.
    $self->param('pgn_round').
    '|outer:'.
    $self->param('pgn_outer').
    '|annot_numb:'.
    $self->param('annot_numb').
    '|pgn_place:'.
    $self->param('pgn_place');
    $self->spurt($str_for_store, $self->top_config->{'pagination_attr_file'});
    $self->redirect_to('/pagination_articl');
}
my( $ref_pagination_attr ) = $self->routine_model->pagination_attr( $self );

$self->render(
pagination_attr => $ref_pagination_attr,
title => $self->lang_config->{'labels'}->{$self->language}->{'pagination_attr'},
);
}#-------------
1;