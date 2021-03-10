package ImageFeatr;
use Mojo::Base 'Mojolicious::Controller';
use Cwd;

#-----------------------------
sub lead_image {
#-----------------------------
my($c, $self, $table) = @_;
my $path_for_upload = $self->top_config->{$self->top_config->{'path_upload_hash'}->{'img'}};
my $lead_img_exist = $self->menu->find( $table, 
                                        ['lead_img'], 
                                        {id => $self->param('id')} )->list;

RewriteImage->lead_img( $self, 
                        cwd().'/public/'.$path_for_upload, 
                        $self->param('lead_img')
                      );
}#---------

#-----------------------------
sub alt_attr {
#-----------------------------
my($c, $self) = @_;
my @alt_param_names;
    
foreach my $param_name( EveryParam->get_param_names($self) ){
    push @alt_param_names, $param_name if($param_name =~ /^alt\|/);
}
    
foreach my $param_name(@alt_param_names){
    my $alt = $self->param($param_name);
    my $tabl_upl = $self->top_config->{'rel_upload_tables'}->
    { (split(/\_/, (split(/\|/, $param_name))[1]))[1] };
    my $item_id = (split(/\_/, (split(/\|/, $param_name))[1]))[0];
    my $item_file = $self->menu->find( $tabl_upl, 
                                       ['file'], 
                                       {id => $item_id} )->list;
    $self->menu->save( $tabl_upl, {'alt' => $alt}, {file => $item_file} );  
}
}#---------

#-----------------------------
sub library_content {
#-----------------------------
my($c, $self, $source_table, $limit_str, $offset) = @_;
my( %exist_img_file, %hash_for_sorting, @content, @content_sorted, @cont, 
    $total_pages);
my $chapter = $self->param('title_alias');
my $page_id = $self->param('page_id');
my $distinct_file = $self->menu->find( $source_table, ['distinct(file)'] )->flat;
my $distinct_files_lenght = scalar @$distinct_file;

my $exist_images_file = $self->menu->find( $source_table, 
                                           ['file'], 
                                           {
                                            'page_id' => $page_id, 
                                            'title_alias' => $chapter
                                           } 
                                         )->flat;
foreach my $img_file(@$exist_images_file){ $exist_img_file{$img_file} = $img_file; }

$total_pages = int( $distinct_files_lenght/$limit_str );
$total_pages = $total_pages + 1 if( $distinct_files_lenght % $limit_str );

my $i = 0;
foreach my $img_file(@$distinct_file){
    my $res = $self->menu->find( $source_table, 
                                 ['*'], 
                                 {'file' => $img_file} )->hash;
    if( $i >= $offset && $i < $offset + $limit_str ){
        $hash_for_sorting{$res->{id}} = $res;
    }
$i++;
}

foreach my $item( reverse( sort {$a <=> $b} keys %hash_for_sorting ) ){
    push @content_sorted, $hash_for_sorting{$item};
}

return (\%exist_img_file, \@content_sorted, $total_pages);
}#---------

1;