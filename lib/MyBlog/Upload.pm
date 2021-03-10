package MyBlog::Upload;
use Mojo::Base 'Mojolicious::Controller';
use RewriteImage;
use FileName;

#---------------------------
sub upload {
#---------------------------
my $self = shift;

my(%err_hash, $message, $level, $level_id, $head, $empty_form_message);
my $language = $self->language;
my $template = $self->template;
use Cwd;
my $range = 10000;
my $minimum = 100;

my $cwd = cwd();
my $RewrImag = RewriteImage->new;    
my $chapter = $self->param('title_alias');
my $sourse_key = $self->param('sourse_key');
my $request = $self->param('request'); # Вид запиту для отримання даних з таблиці
my $redirect_to = $self->param('redirect_to');
my $page_id     = $self->param('id');
my @required_fields = ('c', 'd', 'e', 'f');

my $indicr;
my @err_arr;
my @err_indicatr;
my $get_valid_list_func = $self->param('valid_format_func');
my $template_for_upload = $self->param('template_for_upload');
my $path_for_upload     = $self->param('path_for_upload');
my $change_filename_status = $self->param('change_filename');

($level, $level_id, $head) = $self->menu->find( $chapter, 
                                                ['level', 'level_id', 'head'], 
                                                {id => $page_id} )->list;

foreach( @required_fields ){
    $self->stash(template => $template_for_upload, $_.'_err' => '');
}

#***********************************
if( $self->param('upload') ){
#***********************************
my @size_arr;
  foreach my $param_name( @required_fields ){
    if( $self->req->upload($param_name)->size > 0 ){
      push @size_arr, $self->req->upload($param_name)->size;
    }
  }
if( scalar @size_arr == 0 ){
  $empty_form_message = $self->lang_config->{empty_form}->{$language};
goto M;
}

foreach my $param_name( @required_fields ){

my $upload_obj = $self->req->upload($param_name);

    my $uploaded_filename = $upload_obj->filename;
    
    if($uploaded_filename){
        $uploaded_filename =~ /(\.\w+)$/;
    
    foreach my $valid_format(@{$self->$get_valid_list_func}){
        if(lc($1) eq $valid_format){ 
            $indicr = 1; 
            last;
        }
        $indicr = 'err'; # if(!$indicr);
    }
        if($indicr eq 'err'){
            $err_hash{$param_name} = 
            $self->serve->err_hash_fields_plus( $self, 
                                                $param_name, 
                                                $self->lang_config->
                                                {'alert'}->{$language}->
                                                {'invalid_format'}.' '.
                                                $uploaded_filename );
            push @err_arr, $indicr;
            next;
        }
    }

}

if( @err_arr ){
    foreach( @required_fields ){
        $self->stash(template => $template_for_upload, $_.'_err' => $err_hash{$_});
    }
goto M;
}
###############################################

foreach my $param_name( @required_fields ){

    my $upload_obj = $self->req->upload($param_name);
    my $uploaded_filename = $upload_obj->filename;
    
    if($uploaded_filename){
        my $alt = $self->param($param_name.'_alt');
    
        if($template_for_upload =~ /\_image$/){
            $uploaded_filename = $param_name.time().
                                 FileName->image_file( $uploaded_filename );
        }
        else{
            if( $change_filename_status ){
                $uploaded_filename = $uploaded_filename;
            }else{
                $uploaded_filename = $param_name.time().
                                     FileName->doc_media_file( $uploaded_filename );
            }
        }
        $upload_obj->move_to("public/$path_for_upload/$uploaded_filename");

        if($template_for_upload =~ /\_image$/){
            $RewrImag->illustration( $self, 
                                     $cwd.'/public'.$path_for_upload, 
                                     $uploaded_filename, 'resize'
                                   );
        }
        
        $self->menu->create( $self->top_config->{'upload_populate_options'}->
                             {$template_for_upload}->{'table'},
                               {
                                'level'        => $level,
                                'level_id'     => $level_id,
                                'title_alias'  => $chapter,
                                'page_id'      => $page_id,
                                'path'         => $path_for_upload,
                                'file'         => $uploaded_filename,
                                'alt'          => $alt
                               } 
                   );
    }

}
sleep(1);
$self->redirect_to( $self->url_for("/$redirect_to")->
                    query(
                          title_alias => $chapter,
                          id          => $page_id,
                          time        => time()
                         )
                  );

}#**************

###################################
M:
$indicr = "";

return $self->render(
        template     => $template_for_upload, 
        language     => $language,
        empty_form_message => $empty_form_message, 
        redirect_to  => $redirect_to,
        title_alias  => $chapter,
        request      => $request,
        id => $page_id,
        head => $head,
        valid_format_func => $get_valid_list_func,
        template_for_upload => $template_for_upload,
        path_for_upload => $path_for_upload,
        title       => $self->lang_config->{'buttons'}->{$language}->{$sourse_key},
        header => $self->lang_config->{'labels'}->{$language}->{'masterroom'}
        );
}#-------------
1;