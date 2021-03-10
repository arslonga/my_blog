package MyBlog::Join;
use Mojo::Base 'Mojolicious::Controller';
use EveryParam;
use ImageFeatr;

#---------------------------
sub image {
#---------------------------
my $self = shift;

my($ref_exist_img_file, $ref_pagination_attr, @content, @content_sorted, @cont, $content,
$level, $level_id, $head, $limit_str, $current_page, $total_pages, $offset);
my $language = $self->language;

my $redirect_to = $self->param('redirect_to');
my $chapter = $self->param('title_alias');
my $page_id     = $self->param('page_id');
my $template_for_upload = $self->param('template_for_upload');
my $path_for_upload     = $self->param('path_for_upload');
my $source_table = 
$self->top_config->{'upload_populate_options'}->{$template_for_upload}->{'table'};

( $ref_pagination_attr, 
  $current_page, 
  $limit_str, 
  $offset ) = $self->routine_model->pagination_attr( $self, 'pagination_attr_image' );
  
($level, $level_id, $head) = $self->menu->find( $chapter, 
                                                ['level', 'level_id', 'head'], 
                                                {id => $page_id} 
                                              )->list;

#********************************
if($self->param('join')){
#********************************
    foreach my $curr_file( EveryParam->get_array_params($self, 'illustr') ){
        my($path, $alt) = $self->menu->find( $source_table, 
                                             ['path', 'alt'], 
                                             {'file' => $curr_file}
                                           )->list;
        my $exist_id = $self->menu->find( $source_table, 
                                          ['id'], 
                                          {-and => ['page_id' => 0, 
                                                    'title_alias'  => $chapter, 
                                                    'file' => $curr_file
                                                   ]
                                          } )->list;
        if($exist_id){ 
            $self->menu->save( $source_table, 
                               {'page_id' => $page_id}, 
                               {-and => ['page_id' => 0, 'id' => $exist_id]} 
                             ); 
        }else{ 
            $self->menu->create( $source_table,
                               {
                                'level'        => $level,
                                'level_id'     => $level_id,
                                'title_alias'  => $chapter,
                                'page_id'      => $page_id,
                                'path'         => $path,
                                'file'         => $curr_file,
                                'alt'          => $alt
                               } 
                   ); 
        }
    }
$self->redirect_to($self->url_for("/$redirect_to")->query(
                                                            title_alias  => $chapter,
                                                            id           => $page_id
                                                         )
                   );
}#*************
( $ref_exist_img_file, 
  $content, 
  $total_pages ) = ImageFeatr->library_content($self, $source_table, $limit_str, $offset);

EN1:
$self->render(
language     => $language, 
redirect_to  => $redirect_to,
title_alias  => $chapter,
template_for_upload => $template_for_upload,
page_id => $page_id,
head => $head,
current_page => $current_page,
total_pages => $total_pages,
limit_str => $limit_str,
pagination_attr => $ref_pagination_attr,
exist_img_file => $ref_exist_img_file,
content => $content,
title  => $self->lang_config->{'join_images'}->{$language},
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'}
);
}#-------------

#---------------------------
sub document {
#---------------------------
my $self = shift;

my($ref_exist_img_file, $ref_pagination_attr, @content, @cont, $content,
$level, $level_id, $head, $limit_str, $current_page, $total_pages, $offset);
my $language = $self->language;

my $redirect_to = $self->param('redirect_to');
my $chapter = $self->param('title_alias');
my $page_id     = $self->param('page_id');
my $template_for_upload = $self->param('template_for_upload');
my $path_for_upload     = $self->param('path_for_upload');
my $source_table = 
$self->top_config->{'upload_populate_options'}->{$template_for_upload}->{'table'};

( $ref_pagination_attr, 
  $current_page, 
  $limit_str, 
  $offset ) = $self->routine_model->pagination_attr($self, 'pagination_attr_image');
($level, $level_id, $head) = $self->menu->find( $chapter, 
                                                ['level', 'level_id', 'head'], 
                                                {id => $page_id}
                                              )->list;

#********************************
if($self->param('join')){
#********************************
    foreach my $curr_file(EveryParam->get_array_params($self, 'document')){
        my($path, $alt) = $self->menu->find( $source_table, 
                                             ['path', 'alt'], 
                                             {'file' => $curr_file}
                                           )->list;
        my $exist_id = $self->menu->find( $source_table, 
                                          ['id'], 
                                          {-and => ['page_id' => 0, 
                                                    'title_alias'  => $chapter, 
                                                    'file' => $curr_file
                                                   ]
                                          } )->list;
        if($exist_id){ 
            $self->menu->save( $source_table, 
                               {'page_id' => $page_id}, 
                               {-and => ['page_id' => 0, 'id' => $exist_id]} 
                             ); 
        }else{ 
            $self->menu->create( $source_table,
                               {
                                'level'        => $level,
                                'level_id'     => $level_id,
                                'title_alias'  => $chapter,
                                'page_id'      => $page_id,
                                'path'         => $path,
                                'file'         => $curr_file,
                                'alt'          => $alt
                               } 
                   ); 
        }    
    }
$self->redirect_to($self->url_for("/$redirect_to")->query(
                                                            title_alias  => $chapter,
                                                            id           => $page_id
                                                         )
                   );
}#*************

( $ref_exist_img_file, 
  $content, 
  $total_pages ) = ImageFeatr->library_content($self, $source_table, $limit_str, $offset);

return $self->render(
language     => $language, 
redirect_to  => $redirect_to,
title_alias  => $chapter,
template_for_upload => $template_for_upload,
page_id => $page_id,
head => $head,
current_page => $current_page,
total_pages => $total_pages,
limit_str => $limit_str,
pagination_attr => $ref_pagination_attr,
exist_img_file => $ref_exist_img_file,
content => $content,
title  => $self->lang_config->{'join_documents'}->{$language},
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'}
);
}#-------------

#---------------------------
sub media {
#---------------------------
my $self = shift;

my($ref_exist_img_file, $ref_pagination_attr, @content, @cont, $content,
$level, $level_id, $head, $limit_str, $current_page, $total_pages, $offset);
my $language = $self->language;

my $redirect_to = $self->param('redirect_to');
my $chapter = $self->param('title_alias');
my $page_id     = $self->param('page_id');
my $template_for_upload = $self->param('template_for_upload');
my $path_for_upload     = $self->param('path_for_upload');
my $source_table = 
$self->top_config->{'upload_populate_options'}->{$template_for_upload}->{'table'};

( $ref_pagination_attr, 
  $current_page, 
  $limit_str, 
  $offset ) = $self->routine_model->pagination_attr($self, 'pagination_attr_image');
($level, $level_id, $head) = $self->menu->find( $chapter, 
                                                ['level', 'level_id', 'head'], 
                                                {id => $page_id}
                                              )->list;

#********************************
if($self->param('join')){
#********************************
    foreach my $curr_file(EveryParam->get_array_params($self, 'media')){
        my($path, $alt) = $self->menu->find( $source_table, 
                                             ['path', 'alt'], 
                                             {'file' => $curr_file}
                                           )->list;
        my $exist_id = $self->menu->find( $source_table, 
                                          ['id'], 
                                          {-and => ['page_id' => 0, 
                                                    'title_alias'  => $chapter, 
                                                    'file' => $curr_file
                                                   ]
                                          } )->list;
        if($exist_id){ 
            $self->menu->save( $source_table, {'page_id' => $page_id}, {-and => ['page_id' => 0, 'id' => $exist_id]} ); 
        }else{ 
            $self->menu->create( $source_table,
                               {
                                'level'        => $level,
                                'level_id'     => $level_id,
                                'title_alias'  => $chapter,
                                'page_id'      => $page_id,
                                'path'         => $path,
                                'file'         => $curr_file,
                                'alt'          => $alt
                               } 
                   ); 
        }    
    }
$self->redirect_to($self->url_for("/$redirect_to")->query(
                                                            title_alias  => $chapter,
                                                            id           => $page_id
                                                         )
                   );
}#*************

( $ref_exist_img_file, 
  $content, 
  $total_pages ) = ImageFeatr->library_content($self, $source_table, $limit_str, $offset);

return $self->render(
language     => $language, 
redirect_to  => $redirect_to,
title_alias  => $chapter,
template_for_upload => $template_for_upload,
page_id => $page_id,
head => $head,
current_page => $current_page,
total_pages => $total_pages,
limit_str => $limit_str,
pagination_attr => $ref_pagination_attr,
exist_img_file => $ref_exist_img_file,
content => $content,
title  => $self->lang_config->{'join_media'}->{$language},
header => $self->lang_config->{'labels'}->{$language}->{'masterroom'}
);
}#-------------
1;