package DB::Creat;
use Mojo::Base -base;
use base 'DB';


has 'db';

#----------------------------------------------
sub create_tablemysql{
#----------------------------------------------
my $self = shift;
my $c = shift;
my($tab_name, $key);

if(@_){ ($tab_name, $key) = @_; }

$self = {
		'level' => sub{
                        eval{
                            $c->db->query(qq[create table $tab_name(
                                        level varchar(7),
                                        id int(3) auto_increment,
										parent_dir varchar(100) not null,
                                        title varchar(100) not null,
                                        title_alias varchar(100) not null, 
                                        url varchar(100) not null, 
                                        template varchar(15) not null, 
                                        description varchar(255), 
                                        keywords varchar(255),
                                        list_enable varchar(3),
                                        children VARCHAR(3),
										queue int(3),
                                        order_for_time varchar(10),
                                        in_menu varchar(3),
                                        menu TEXT,
                                        PRIMARY KEY(id)
                                        );]
                                        );
							   };
                            return;
                            },
                            
        'main' => sub{
                        eval{
                            $c->db->query(qq[create table  $tab_name(
                                        id int(3) auto_increment,
                                        level varchar(7) not null,
                                        level_id int(3) not null,
                                        rubric_id int(3), 
                                        curr_date datetime not null, 
                                        head varchar(250) not null,
                                        url varchar(255), 
                                        lead_img varchar(250),
                                        announce mediumtext not null,  
                                        content TEXT,
                                        description varchar(255),
                                        keywords varchar(255),
                                        tw_opengraph text,
                                        author_id int(5),
                                        template varchar(15) not null,
                                        comment_enable varchar(3),
                                        liked int(4) not null,
                                        unliked int(4) not null,
                                        inclusion text,
                                        PRIMARY KEY(id)
                                        );]
                                        );

							   };
                            return;
                            }
        };

return $self->{$key}->($tab_name);
}#---------------

#----------------------------------------------
sub create_tablePg {
#----------------------------------------------
my $self = shift;
my $c = shift;
my($tab_name, $key);

if(@_){ ($tab_name, $key) = @_; }

$self = {
		'level' => sub{
                        eval{
                            $c->db->query(qq[create table $tab_name(
										   	 level varchar(7),
                                          	 id serial,
											 parent_dir varchar(100),
                                          	 title varchar(100),
                                             title_alias varchar(100), 
                                          	 url varchar(100), 
                                          	 template varchar(15), 
                                          	 description varchar(255), 
                                          	 keywords varchar(255),
                                          	 list_enable varchar(3),
                                             children VARCHAR(3),
											 queue int,
                                             order_for_time varchar(10),
                                             in_menu varchar(3),
                                             menu TEXT,
                                             PRIMARY KEY(id)
                                             );]
                                            );
							   };
                            return;
                            },
                            
        'main' => sub{
                        eval{
                            $c->db->query(qq[create table  $tab_name(
                                        id serial,
                                        level varchar(7),
                                        level_id int not null,
                                        rubric_id int, 
                                        curr_date timestamp, 
                                        head varchar(250),
                                        url varchar(255), 
                                        lead_img varchar(250),
                                        announce text,  
                                        content TEXT,
                                        description varchar(255),
                                        keywords varchar(255),
                                        tw_opengraph text,
                                        author_id int,
                                        template varchar(15),
                                        comment_enable varchar(3),
                                        liked int not null,
                                        unliked int not null,
                                        inclusion text,
                                        PRIMARY KEY(id)
                                        );]
                                        );

							   };
                            return;
                            }
        };

return $self->{$key}->($tab_name);
}#---------------

#-------------------------------------
sub create_db_structure_Pg{
#-------------------------------------
my $self = shift;
my $c = shift;
my($action, $tab_name);

if(@_){ ($action, $tab_name) = @_; }

$self = {
    'user_passw' => sub{
                        eval{
                        $c->db->query(qq[create table $tab_name(
                                        admin VARCHAR(50),
                                        password VARCHAR(50),
                                        email VARCHAR(50)
                                        );]
                        );
                        };
                        return 1;
                       },
                       
    'illustrations' => sub{
                        eval{
                        $c->db->query(qq[
                                        create table $tab_name(
                                        id serial,
                                        level VARCHAR(7),
                                        level_id INT not null,
                                        title_alias VARCHAR(100), 
                                        page_id INT not null, 
                                        path varchar(250), 
                                        file varchar(100), 
                                        alt varchar(255),
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        };
                        
                        $c->db->query(q{CREATE INDEX CONCURRENTLY page_id_index ON illustrations (page_id, file);});
                        return 1;
                       },
                       
    'documents' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id serial,
                                        level VARCHAR(7),
                                        level_id INT not null,
                                        title_alias VARCHAR(100), 
                                        page_id INT not null, 
                                        path varchar(250), 
                                        file varchar(100), 
                                        alt varchar(255),
                                        PRIMARY KEY(id)
                                    );]
                                    );
                         $c->db->query(q{CREATE INDEX CONCURRENTLY page_id_file_index ON documents (page_id, file);});
                        return 1;
                       },
                       
    'media' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id serial,
                                        level VARCHAR(7),
                                        level_id INT not null,
                                        title_alias VARCHAR(100), 
                                        page_id INT not null, 
                                        path varchar(250), 
                                        file varchar(100),
                                        alt varchar(255), 
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        $c->db->query(q{CREATE INDEX CONCURRENTLY page_file_index ON media (page_id, file);});
                        return 1;
                       },
                       
        'auser' => sub{
                       $c->db->query(qq[create table $tab_name(
                                        id serial, 
                                        curr_date timestamp,  
                                        login varchar(50), 
                                        pass varchar(100), 
                                        email varchar(100),
                                        comment_quant int,
                                        view_status varchar(4),
                                        newsletter varchar(4),
                                        edit_priority text,
                                        banned varchar(4),
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       },
                       
        'rubric' => sub{
                       $c->db->query(qq[create table $tab_name(
                                        id serial, 
                                        rubric varchar(254),
                                        PRIMARY KEY(id)
                                    );]
                                    );

                        return 1;
                       },        
                       
    'comments_artcl' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id serial,
                                        curr_date timestamp,
                                        parent_id INT not null,
                                        level INT not null,
                                        menu_level VARCHAR(10),
                                        nickname VARCHAR(100),
                                        name VARCHAR(100),
                                        table_name VARCHAR(100),
                                        page_id INT not null, 
                                        url VARCHAR(250),
                                        comment TEXT, 
                                        press_indicat VARCHAR(3),
                                        liked INT,
                                        unliked INT,
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        $c->db->query(q{CREATE INDEX CONCURRENTLY comments_index ON comments_artcl (page_id, table_name, level, nickname, parent_id, menu_level);});
                        return 1;
                       },
                       
    'search' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id serial,
                                        url VARCHAR(250),
                                        table_name VARCHAR(250),
                                        page_id INT not null,
                                        head VARCHAR(250),
                                        description VARCHAR(250),
                                        search_text TEXT,
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       },
                       
    'archive_menu' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id serial,
                                        url VARCHAR(250),
                                        menu TEXT,
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       },
                       
    'rss_setting' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id serial,
                                        title TEXT,
                                        description TEXT,
                                        list_number INT not null,
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       },
                       
    'rss_data' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        curr_date timestamp,
                                        level VARCHAR(7),
                                        page_id INT not null,
                                        table_name VARCHAR(255),
                                        url VARCHAR(255),
                                        description TEXT,
                                        category TEXT,
                                        PRIMARY KEY(curr_date)
                                    );]
                                    );
                        return 1;
                       },
                       
    'carousel' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id serial,
                                        image_file varchar(255),
                                        queue int,
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       }
};
return $self->{$action}->();
}#-----------

#-------------------------------------
sub create_db_structure_mysql{
#-------------------------------------
my $self = shift;
my $c = shift;
my($action, $tab_name);

if(@_){ ($action, $tab_name) = @_; }

$self = {
    'user_passw' => sub{
                        eval{
                        $c->db->query(qq[
                                        CREATE TABLE $tab_name(
                                        admin VARCHAR(50) not null,
                                        password VARCHAR(50) not null,
                                        email VARCHAR(50) not null
                                        );]
                        );
                        };
                        return 1;
                       },
                       
    'illustrations' => sub{
                        eval{
                        $c->db->query(qq[create table $tab_name(
                                        id INT(4) auto_increment,
                                        level VARCHAR(7) not null,
                                        level_id INT(4) not null,
                                        title_alias VARCHAR(100) not null, 
                                        page_id INT(5) not null, 
                                        path varchar(250) not null, 
                                        file varchar(100) not null, 
                                        alt varchar(255) not null,
                                        INDEX page_id_index(page_id, file),
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        };
                        return 1;
                       },
                       
    'documents' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id INT(4) auto_increment,
                                        level VARCHAR(7) not null,
                                        level_id INT(4) not null,
                                        title_alias VARCHAR(100) not null, 
                                        page_id INT(5) not null, 
                                        path varchar(250) not null, 
                                        file varchar(100) not null, 
                                        alt varchar(255) not null,
                                        INDEX page_id_index(page_id, file),
                                        PRIMARY KEY(id)
                                    );]
                                    );

                        return 1;
                       },
                       
    'media' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id INT(4) auto_increment,
                                        level VARCHAR(7) not null,
                                        level_id INT(4) not null,
                                        title_alias VARCHAR(100) not null, 
                                        page_id INT(5) not null, 
                                        path varchar(250) not null, 
                                        file varchar(100) not null,
                                        alt varchar(255) not null, 
                                        INDEX page_id_index(page_id, file),
                                        PRIMARY KEY(id)
                                    );]
                                    );

                        return 1;
                       },
                       
        'auser' => sub{
                       $c->db->query(qq[create table $tab_name(
                                        id int(4) auto_increment, 
                                        curr_date datetime not null,  
                                        login varchar(50) not null, 
                                        pass varchar(100) not null, 
                                        email varchar(100) not null,
                                        comment_quant int(4),
                                        view_status varchar(4),
                                        newsletter varchar(4),
                                        edit_priority text,
                                        banned varchar(4),
                                        PRIMARY KEY(id)
                                    );]
                                    );

                        return 1;
                       },
                       
        'rubric' => sub{
                       $c->db->query(qq[create table $tab_name(
                                        id int(3) auto_increment, 
                                        rubric varchar(254) not null,
                                        PRIMARY KEY(id)
                                    );]
                                    );

                        return 1;
                       },        
                       
    'comments_artcl' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id INT(4) auto_increment,
                                        curr_date DATETIME not null,
                                        parent_id INT(4),
                                        level INT(4),
                                        menu_level VARCHAR(10) not null,
                                        nickname VARCHAR(100) not null,
                                        name VARCHAR(100) not null,
                                        table_name VARCHAR(100) not null,
                                        page_id INT(4) not null, 
                                        url VARCHAR(250) not null,
                                        comment TEXT, 
                                        press_indicat VARCHAR(3),
                                        liked INT(4),
                                        unliked INT(4),
                                        INDEX columnindex(page_id, table_name, level, nickname, parent_id, menu_level),
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       },
                       
    'search' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id INT(4) auto_increment,
                                        url VARCHAR(250) not null,
                                        table_name VARCHAR(250) not null,
                                        page_id INT(3) not null,
                                        head VARCHAR(250) not null,
                                        description VARCHAR(250) not null,
                                        search_text TEXT not null,
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       },
                       
    'archive_menu' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id INT(4) auto_increment,
                                        url VARCHAR(250) not null,
                                        menu TEXT not null,
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       },
                       
    'rss_setting' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id INT(4) auto_increment,
                                        title TINYTEXT not null,
                                        description TINYTEXT not null,
                                        list_number INT(2) not null,
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       },
                       
    'rss_data' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        curr_date DATETIME not null,
                                        level VARCHAR(7) not null,
                                        page_id INT(5) not null,
                                        table_name VARCHAR(255) not null,
                                        url VARCHAR(255) not null,
                                        description TEXT not null,
                                        category TINYTEXT not null,
                                        PRIMARY KEY(curr_date)
                                    );]
                                    );
                        return 1;
                       },
                       
    'carousel' => sub{
                        $c->db->query(qq[create table $tab_name(
                                        id int(4) auto_increment,
                                        image_file varchar(255),
                                        queue int(3),
                                        PRIMARY KEY(id)
                                    );]
                                    );
                        return 1;
                       }
};
return $self->{$action}->();
}#-----------
1;