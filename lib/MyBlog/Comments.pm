package MyBlog::Comments;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------
sub comments_setting {
#---------------------------
my $self = shift;
my $table_comments = $self->top_config->{'table'}->{'comments'};
my $comments_levels_deep_file = $self->top_config->{'comments_levels_deep_file'};
my $list_of_levels = $self->top_config->{'comments_deep_levels'};

my $comments_showed_numbers_file = $self->top_config->{'comments_showed_numbers_file'};
my $list_of_showed_comments_numbers = $self->top_config->{'comments_showed_number'};
my $comments_numbers_step_file = $self->top_config->{'comments_numbers_step_file'};
my $list_of_comments_step = $self->top_config->{'comments_showed_step'};
my($exist_comments_deep, $exist_comments_numbers, $exist_comments_step);

#***************************
if($self->param('comments_deep')){
#***************************
    $self->menu->save( $table_comments, {level => $self->param('comments_deep')}, 
                                  { level => {'>', $self->param('comments_deep')} } );
    $self->spurt($self->param('comments_deep'), $comments_levels_deep_file);
    $self->spurt($self->param('comments_showed'), $comments_showed_numbers_file);
    $self->spurt($self->param('comments_step'), $comments_numbers_step_file);
$self->redirect_to('/comments_setting');
}#***********
eval{ 
$exist_comments_deep    = $self->slurp( $comments_levels_deep_file );
$exist_comments_numbers = $self->slurp( $comments_showed_numbers_file );
$exist_comments_step    = $self->slurp( $comments_numbers_step_file );
};

$self->render(
list_of_levels => $list_of_levels,
exist_comments_deep => $exist_comments_deep,
list_of_showed_comments_numbers => $list_of_showed_comments_numbers,
exist_comments_numbers => $exist_comments_numbers,
list_of_comments_step => $list_of_comments_step,
exist_comments_step => $exist_comments_step,
header => $self->lang_config->{'labels'}->{$self->language}->{'masterroom'},
title => $self->lang_config->{'labels'}->{$self->language}->{'comments_setting'},
head => $self->lang_config->{'labels'}->{$self->language}->{'comments_setting'},
);
}#-------------
1;