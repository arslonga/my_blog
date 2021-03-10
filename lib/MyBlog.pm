package MyBlog;
use Mojo::Base 'Mojolicious';

use DB;
use Moj::Util;
use Mojo::Util qw(trim);
use MyBlog::Model::Menu;
use Serve;
use MyBlog::RegExp;
use Mojolicious::Plugins;
use SessCheck;
use Captcha;
my $plugins = Mojolicious::Plugins->new;
push @{$plugins->namespaces}, 'MyBlog::Plugin';
$plugins->register_plugin( 'MyBlog::Plugin::BootstrapPgn', Mojolicious->new );

#----------------------------------------
sub startup {
#----------------------------------------
  my $self = shift;
  my $config = $self->plugin('Config');
  $self->secrets( $self->config('secrets') );
  #$self->mode( $self->config->{mode} );
  
  $self->max_request_size(20000000);
  $self->plugin( 'MyBlog::Plugin::BootstrapPgn' );
  
  $self->helper( slurp => sub { my($self, $path) = @_ if(@_); return Moj::Util->slurp($path) } );
  $self->helper( spurt => sub { my($self, $content, $path) = @_ if(@_); return Moj::Util->spurt($content, $path) } );
  # Plugin for creating helpers
  $self->plugin('MyBlog::Helpers');

  # Helper for the object of theme routine
  $self->helper( template => sub { $self->slurp('conf/work_routine') });
  
  require 'MyBlog/Controller/'.$self->template.'.pm';
  require 'MyBlog/Model/'.$self->template.'.pm';
  #require $self->template.'/Serve.pm';
  require $self->template.'/TitleAliasList.pm';
  require $self->template.'/RewrMenu.pm';
  require $self->template.'/ArticleProper.pm';
  require $self->template.'/Archive.pm';
  my $NAMESPACE = "MyBlog::Controller::".$self->template;

  $self->helper( top_config => sub {$self->plugin('JSONConfig', {file => 'conf/'.$self->template.'/top_conf.json'})} );
  $self->helper( dbconfig => sub {$self->plugin('Config', {file => 'conf/'.$self->language.'/comirka.conf'})} );
  
    # Helper to determine the display of the authorization form
    $self->helper( authorize_enable => sub { $self->slurp($self->top_config->{'authorize_setting_file'}) } );
    $self->helper( msg_files => sub {
                                    my @FILES;
                                    opendir(THISDIR, 'conf/'.$self->language);
                                    @FILES = grep(!/^\.\.?$/, readdir THISDIR); 
                                    closedir(THISDIR);
                                    return \@FILES;				
                                   } );
    
    $self->helper( lang_config => sub {state $lang_conf = $self->plugin('JSONConfig', {file => 'conf/lang_conf.json'})} );
    # Helper for description of determine theme features
    $self->helper( routine_description => sub { $self->slurp('conf/'.$self->template.'/'.$self->language.'/description') } );   
    $self->helper( db_driver => sub { trim( $self->slurp('conf/'.$self->language.'/'.$self->top_config->{'db_driver_file'}) ) } );
    $self->helper( thumb_img_style => sub { $self->slurp('conf/thumb_img_style') });
    $self->helper( clean_text => sub { my $self = shift;
        my $arg = shift if(@_); $arg =~ s/\&nbsp\;/ /g;
                                $arg =~ s/\&raquo\;/ /g;
                                $arg =~ s/\&mdash\;/ /g;
                                $arg =~ s/\&laquo\;/ /g;
                                $arg =~ s/\&rsquo\;//g;
                                $arg =~ s/\s+/ /g;
                                $arg =~ s/\<[^<>]+\>//g;
                                $arg =~ s/[&;`\\|\"\*?~^()\$\n\r]+//g;
        return $arg; 
    } );
    $self->helper(regexp => sub { MyBlog::RegExp->new()} );
    $self->helper(captcha => sub { Captcha->new });
    
  my $template = $self->template;
  
  my($db, $err) = DB->connect_db($self);

  $self->helper( db => sub { state $db = DB->connect_db( $self) } );
  $self->helper( db_table => sub { DB::Table->new( db => shift->db ) } );
  $self->helper( db_select => sub { DB::Select->new( db => shift->db ) } );
  $self->helper( db_create => sub { DB::Creat->new( db => shift->db ) } );
  # Helper for the object of determine theme routine
  $self->helper( routine => sub { $NAMESPACE } );
  $self->helper( captcha => sub { Captcha->new } );
  $self->helper( menu => sub { state $menu = MyBlog::Model::Menu->new( db => $self->db ) } );    
  $self->helper( serve => sub { Serve->new( db => $self->db, menu => $self->menu ) } );
  $self->helper( routine_model => sub { my $self = shift; 
                                       #state $routine_model = "MyBlog::Model::".$self->template( db => $self->db ) 
                                       state $routine_model = "MyBlog::Model::".$self->template; 
                                      }
               );
  $self->helper( sess_check => sub { SessCheck->new } );

  # Router
  my $r = $self->routes;

  # Normal route to controller
  $r->any('/dbaccess')->to('author#dbaccess');
  $r->any('/access')->to('author#access');
  $r->any('/admin')->to('author#admin');
  $r->any('/dbdriver')->to('author#dbdriver');
  
  $r->any('/user.admin')->to('author#user_admin');
  $r->any('/user/forgot-passw')->to('users#forgot_passw');
  $r->any('/registration')->to('login-auth#registration_sess');
  $r->any('/authentication')->to('login-auth#authentication');
  
  #======================================= Admin routes ========================
  
  my $logged_in = $r->under->to('login#logged_in');
  my $user_logged_in = $r->under->to('login#user_logged_in');
  $logged_in->any('/manager')->to('manager#start');
  $logged_in->any('/menu_manage')->to('menu#menu_manage')->name('menu_manage');
  
  $user_logged_in->any('/user.menu_manage')->to('menu#user_menu_manage')->name('user.menu_manage');
  $user_logged_in->any('/user_list_content_manage')->to('list#user_list_content');
  $user_logged_in->any('/user.article_manage')->to('list#user_article');
  $user_logged_in->any('/user.add_rubric')->to('rubric#add_rubric');
  $user_logged_in->any('/user.edit_rubric')->to('rubric#edit_rubric');
  $user_logged_in->any('/user.upload_image')->to('upload#upload')->name('upload_image');
  $user_logged_in->any('/user.upload_document')->to('upload#upload')->name('upload_document');
  $user_logged_in->any('/user.upload_media')->to('upload#upload')->name('upload_media');
  $user_logged_in->any('/user/profile')->to('users#profile');
  
  $logged_in->any('/favicon')->to('manager#favicon')->name('favicon');
  
  $logged_in->any('/theme_manage')->to('manager#theme')->name('theme_manage');
  $logged_in->any('/logo.manage')->to('manager#logo_manage')->name('logo.manage');
  $logged_in->any('/logo.set_img')->to('logo#logo_set_img')->name('logo.set_img');
  $logged_in->any('/logo.set_bg')->to('logo#logo_set_bg')->name('logo.set_bg');
  $logged_in->any('/logo.set_slideshow')->to('logo#logo_set_slideshow')->name('logo_set_slideshow');
  $logged_in->any('/setbrand')->to('logo#set_brand')->name('setbrand');
  $logged_in->any('/users.manage')->to('users#manage')->name('users.manage');
  $logged_in->any('/user.properties')->to('users#properties')->name('user.properties');
  $logged_in->any('/comments_list')->to('users#comments_list')->name('comments_list');
  $logged_in->any('/user.comment')->to('users#comment')->name('user.comment');
  $logged_in->any('/set.priority_edit')->to('users#priority_edit')->name('set.priority_edit');
  $logged_in->any('/msg.manage')->to('manager#msg_manage')->name('msg.manage');
  $logged_in->any('/admin/authorize_setting')->to('manager#authorize_setting')->name('authorize_setting');
  
  #============================
  $logged_in->any('/admin/sending')->to('sending#sending_kinds')->name('sending_kinds');
  $logged_in->any('/admin/text_sending')->to('sending#text_sending')->name('text_sending');
  $logged_in->any('/admin/text_sending_select')->to('sending#text_sending_select')->name('text_sending_select');
  $logged_in->any('/admin/text_sending_users')->to('sending#text_sending_users')->name('text_sending_users');
  $logged_in->any('/admin/text_sending_tosend')->to('sending#text_sending_tosend');
  #----------------------
  $logged_in->any('/admin/html_sending')->to('sending#html_sending')->name('html_sending');
  $logged_in->any('/admin/html_sending_users')->to('sending#html_sending_users')->name('html_sending_users');
  $logged_in->any('/admin/html_sending_tosend')->to('sending#html_sending_tosend');
  #============================
  
  $logged_in->any('/admin/checkdb')->to('checkdb#check_db')->name('check_db');
  
  $logged_in->any('/admin/social_buttons')->to('manager#social_buttons');
  $logged_in->any('/admin/local_transliter')->to('manager#local_transliter')->name('local_transliter');
  $logged_in->any('/admin/foot')->to('foot#foot')->name('foot');
  $logged_in->any('/admin/article_inclusion')->to('inclusion#article_inclusion')->name('article_inclusion');
  $logged_in->any('/admin/inclusion')->to('inclusion#inclusion')->name('inclusion');
  $logged_in->any('/admin/inclusion_kind')->to('inclusion#inclusion_kind')->name('inclusion_kind');
  $logged_in->any('/admin/routines')->to('manager#routines_list')->name('routines');
  
  $logged_in->any('/list_content_manage')->to('list#list_content');
  $logged_in->any('/article_manage')->to('list#article');
  $logged_in->any('/thumb_img')->to('thumb#thumb_img');
  $logged_in->any('/add_rubric')->to('rubric#add_rubric');
  $logged_in->any('/edit_rubric')->to('rubric#edit_rubric')->name('edit_rubric');
  $logged_in->any('/rubric-setting')->to('rubric#rubric_setting')->name('rubric_setting');
  $logged_in->any('/upload_image')->to('upload#upload')->name('upload_image');
  $logged_in->any('/upload_document')->to('upload#upload')->name('upload_document');
  $logged_in->any('/upload_media')->to('upload#upload')->name('upload_media');
  
  $logged_in->any('/image_library')->to('join#image')->name('image_library');
  $user_logged_in->any('/user.image_library')->to('join#image')->name('image_library');
  $logged_in->any('/document_library')->to('join#document')->name('document_library');
  $user_logged_in->any('/user.document_library')->to('join#document')->name('document_library');
  $logged_in->any('/media_library')->to('join#media')->name('media_library');
  $user_logged_in->any('/user.media_library')->to('join#media')->name('media_library');
  
  $logged_in->any('/comments_setting')->to('comments#comments_setting');
  $logged_in->any('/rss_setting')->to('rss#rss_setting');
  $logged_in->any('/pagination_articl')->to('pagination#pgn_articl');
  
  #======================================= Admin routes END ====================
 
  $r->any('/likeartcl')->to('likeartcl#respnse')->name('likeartcl');
  $r->any('/unlikeartcl')->to('unlikeartcl#respnse')->name('unlikeartcl');
  
  $r->any('/like')->to('like#responce')->name('like');
  $r->any('/unlike')->to('unlike#responce')->name('unlike');
  
  $r->any('/rubric/:id', [ id => qr/[0-9]+/ ])->to(namespace => 'RubricList', action => 'show_rubrics');
  $r->any('/all.rubrics')->to(namespace => 'RubricList', action => 'show_all');
  $r->any('/view.user')->to(namespace => $template.'::ViewUser', action => 'user_comments');
  $r->any('/user.allposts')->to(namespace => $template.'::ViewUser', action => 'user_posts');
  $r->any('/sitemap')->to('sitemap#sitemap')->name('sitemap');
  $r->any('/articles-feed')->to('rss#articles_feed')->name('articles-feed');
  $r->any('/comments-feed')->to('rss#comments_feed')->name('comments-feed');
  $r->any('/archive/:year/:month')->to($self->template.'#archive', year => qr/\d{4}/, month => qr/\d{2}/);
  $r->any('/search_artcl')->to('searching#search_artcl')->name('search_artcl');
  
  # You can use the namespace determined with the determined template  !!!!!!!!! 
  #$r->any('/foo')->to(namespace => $template.'::Foo', action => 'foo')->name('foo');
  
  $r->any('/:chapter', [ chapter => qr/[\d\_a-zA-Z]+/ ])->to($self->template.'#index');
  $r->any('/:chapter/:subchapter', [ chapter => qr/[\d\_a-zA-Z]+/, 
                                     subchapter => qr/[\d\_a-zA-Z]+/ ])
                                     #->via('GET', 'POST')
                                     ->to($self->template.'#index');
  $r->any('/:chapter/:id/:article', [ chapter => qr/[\d\_a-zA-Z]+/,
                                      id => qr/[0-9]+/, 
                                      article => qr/[\w\d\-\s\.]+/ ] )
                                      ->to($self->template.'#article');
  $r->any('/:chapter/:subchapter/:id/:article', [ chapter => qr/[\d\_a-zA-Z]+/,
                                                  subchapter => qr/[\d\_a-zA-Z]+/,
                                                  id => qr/[0-9]+/, 
                                                  article => qr/[\w\d\-]+/ ])
                                                  ->to($self->template.'#article');

  $r->any('/')->to( namespace => $NAMESPACE, action => 'main' )->name('main');

}#------------
1;