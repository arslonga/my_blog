package DeleteFile;
use Mojo::Base 'Mojolicious::Controller';
use EveryParam;

#-------------------------------------
sub delete{
#-------------------------------------
my $self = shift;
my($c) = @_;

if($c->param('delete_illustr')){

    foreach my $id_file( EveryParam->get_array_del($c, 'delete_illustr') ){
        my($id, $file) = split(/\|/, $id_file);        
        $c->menu->save( 'illustrations', {'page_id' => 0}, {'id' => $id} );
    }
}

if($c->param('delete_doc')){

    foreach my $id_file( EveryParam->get_array_del($c, 'delete_doc') ){
        my($id, $file) = split(/\|/, $id_file);        
        $c->menu->save( 'documents', {'page_id' => 0}, {'id' => $id} );
    }
}

if($c->param('delete_media')){

    foreach my $id_file( EveryParam->get_array_del($c, 'delete_media') ){
        my($id, $file) = split(/\|/, $id_file);
        $c->menu->save( 'media', {'page_id' => 0}, {'id' => $id} );
    }
}
            
return;
}#---------------

#-------------------------------------
sub delete_slide {
#-------------------------------------
my($self, $c) = @_;
my $slideshow_table = $c->top_config->{'table'}->{'slideshow'};

if($c->param('image_id')){
    my $slide = $c->menu->find( $slideshow_table, 
                                ['image_file'], 
                                {'id' => $c->param('image_id')}
                              )->list;
    $c->menu->delete($slideshow_table, {'id' => $c->param('image_id')});
    unlink 'public/'.$c->top_config->{'slides_image_path'}.'/'.$slide;
}

return 1;
}#---------------
1;