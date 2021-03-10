package DB::Insert;
use base 'DB';
use Mojo::Base 'Mojolicious::Controller';

#----------------------------------------------
sub new{
#----------------------------------------------
   my $proto = shift;
   my $class = ref($proto) || $proto;

   my $self = {};

   bless($self, $class);
return $self;
}#-------------

#----------------------------------------------
sub insert{
#----------------------------------------------
my $self = shift;
my $c = shift;
my($tab_name, $key);

if(@_){ ($tab_name, $key) = @_; }

$self = {
    'level0' => sub{                        
                    eval{
                    $c->menu->create($tab_name, {
                                                level       => 'level0',
                                                title       => $c->lang_config->{'labels'}->{$c->language}->{'main'},
                                                title_alias => 'main',
                                                parent_dir  => 'NULL',
                                                url         => '/',
                                                template    => 'article',
                                                list_enable => 'no',
                                                queue       => 0,
                                                in_menu     => 'yes'
                                                });
                            
                        };
                        return;
                    },
                            
    'main' => sub{
                    my $host = $c->protocol.'://'.$c->req->headers->host;
                    my $content = "<img class=\"img-responsive\" src=\"$host/img/img_for_main.jpg\" style=\"margin: 4px 6px; float: left; width: 400px; height: 541px;\">\n";
                    $content.=$c->lang_config->{'loren_ipsum'}->{$c->language}."<br>\n";
                    eval{
                    $c->menu->create($tab_name, {
                                                level       => 'level0',
                                                level_id    => $c->menu->find('level0', ['id'], {title_alias => 'main'})->list,
                                                rubric_id   => 0,
                                                curr_date   => $c->db_table->now($c),
                                                head        => $c->lang_config->{'new_page_content'}->{$c->language},
                                                announce    => $c->lang_config->{'new_page_content'}->{$c->language},
                                                content     => $content,
                                                description => '',
                                                keywords    => '',
                                                author_id   => 0,
                                                template    => 'article',
                                                comment_enable => 'no',
                                                liked     => 0,
                                                unliked   => 0
                                                });
                            
                        };
                        return;
                    }
        };

return $self->{$key}->($tab_name);
}#---------------
1;