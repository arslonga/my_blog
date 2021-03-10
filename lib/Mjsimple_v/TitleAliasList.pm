package TitleAliasList;
use Mojo::Base 'Mojolicious::Controller';

#---------------------------
sub title_alias_list {
#---------------------------
my($self, $c) = @_;
my(@title_alias, @levels);
@title_alias = ();
@levels = @{$c->top_config->{'levels'}};

foreach( @levels ){
    my @title_alias_curr = $c->menu->find( $_, ['distinct(title_alias)'], {'children' => [{'!=', 'yes'}, undef], 'in_menu' => 'yes'} )->flat;
    push @title_alias, @title_alias_curr;
}
return \@title_alias;
}#-------------

#---------------------------
sub title_alias_list_archive {
#---------------------------
my($self, $c) = @_;
my(@title_alias, @levels);
@title_alias = ();
@levels = @{$c->top_config->{'levels'}};

foreach( @levels ){
    my @title_alias_curr = $c->menu->find( $_, ['distinct(title_alias)'], {'children' => [{'!=', 'yes'}, undef], 'in_menu' => 'yes'} )->flat;
    push @title_alias, @title_alias_curr;
}
return \@title_alias;
}#-------------

#---------------------------
sub title_alias_list_for_priorEdit {
#---------------------------
my($self, $c) = @_;
my(@title_alias, @levels);
@title_alias = ();

@levels = @{$c->top_config->{'levels'}};

foreach(@levels){
    my @title_alias_curr = $c->menu->find( $_, ['distinct(title_alias)'], {'children' => [{'!=', 'yes'}, undef], list_enable => 'yes'} )->flat;
    push @title_alias, @title_alias_curr;
}
return \@title_alias;
}#-------------

#---------------------------
sub title_alias_title_list {
#---------------------------
my($self, $c) = @_;
my(@title_alias, @levels);
@title_alias = ();
@levels = @{$c->top_config->{'levels'}};

foreach my $curr_level( @levels ){
    my @title_alias_curr = $c->menu->find( $curr_level, ['distinct(title_alias)'], {'children' => [{'!=', 'yes'}, undef]} )->flat;
    foreach(@title_alias_curr){
        my $title = $c->menu->find( $curr_level, ['title'], {'title_alias' => $_} )->list;
        $_ = $_.'|'.$title;
    }
    push @title_alias, @title_alias_curr;
}
return \@title_alias;
}#-------------
1;