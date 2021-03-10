package Archive;
use Mojo::Base 'Mojolicious::Controller';
use RubricList;

#------------------------------------
sub archive_menu {
#------------------------------------
my($self, $c) = @_;
my $language = $c->language;
my $table_archive_menu = $c->top_config->{'table'}->{'archive_menu'};
my(@title_alias, @year_month, @month, @years, @archive_url, 
   %exist, %exist_year, %year_month, $common_menu, $common_menu_orig);

@title_alias = @{TitleAliasList->title_alias_list_archive( $c )};

foreach my $tbl(@title_alias){
    my $result = $c->db_table->dstnct_date( $c, $tbl );
    while( my($year_month) = $result->list ){
        $year_month = substr($year_month, 0, 7);
        next if($exist{$year_month});
        push @year_month, $year_month;
        $exist{$year_month} = 1;
    }
}

my $i = 0;
foreach(sort @year_month){
    if($exist_year{(split(/-/, $_))[0]}){
        my $yea_r = (split(/-/, $_))[0];
        push @month, (split(/-/, $_))[1];
        $year_month{(split(/-/, $_))[0]} = [@month];
    }else{
        @month = ();
        $exist_year{(split(/-/, $_))[0]} = 1;
        push @month, (split(/-/, $_))[1];
        $year_month{(split(/-/, $_))[0]} = [@month];
    }
$i++;
}

$common_menu = "<div class=\"panel-group\" id=\"accordion\">\n";
foreach my $year(reverse sort keys %year_month){
$common_menu.=<<ARCH_MENU;
<div class="panel">
    <div class="acrd">
        <a data-toggle="collapse" data-parent="#accordion" href="#$year">
          $year
        </a>
    </div>
    <div id="$year" class="panel-collapse collapse">
      <div class="panel-body" id="archive_month_block">
      <ul>
ARCH_MENU

    foreach my $month(@{$year_month{$year}}){
    #----------------------------------
        my $cnt = 0;
        foreach my $tbl(@title_alias){
            my $result = $c->db_table->get_date( $c, $tbl, $year, $month );
            while(my $item = $result->list){
                if($item){
                    $cnt++;
                }
            }
        }
    #----------------------------------        
        push @archive_url, '/archive/'.$year.'/'.$month.'|'.$cnt;
        my $month_name = $c->lang_config->{'num_month'}->{$month}->{$language};
        $common_menu.=<<ARCH_MENU;
<li id="li_archive_month">
<a href="/archive/$year/$month" class="archive_month_label">
    $month_name
</a>
<span class="cnt-arch"> [$cnt]</span>
</li>
ARCH_MENU

    }

$common_menu.=<<ARCH_MENU;
      </ul>
      </div>
    </div>
</div>
ARCH_MENU

}
$common_menu.="</div>\n";

$common_menu_orig = $common_menu;

my($id) = $c->menu->find( $table_archive_menu, 
                          ['id'], 
                          {'url' => 'common'} 
                        )->list;
if(!$id){
    $c->menu->create( $table_archive_menu, 
                      {'url' => 'common', menu => $common_menu} 
                    );
}else{
    $c->menu->save( $table_archive_menu, 
                    {menu => $common_menu}, 
                    {'url' => 'common'} 
                  );
}

    foreach my $curr_url_compl( @archive_url ){
        my($curr_url, $curr_cnt) = split(/\|/, $curr_url_compl);
        
        my $curr_year = (split(/\//, $curr_url))[2];
        if($common_menu =~ /(<div id=")($curr_year)\"\s+class\=\"panel\-collapse\s+collapse\">/){
            $common_menu =~ s/(<div id=")($curr_year)\"\s+class\=\"panel\-collapse\s+collapse\">/${1}${2}\" class\=\"panel-collapse collapse in">/;
        }
        if($common_menu =~ /(\<li[^\/]*)($curr_url)([^>]*>)(\w+<\/a>)/){
            my $senc = $4;
            $common_menu =~ s/${1}${2}${3}${4}.*/<li id\=\"li_archive_month\" class\=\"li_month_disable\">$senc <span class=\"cnt-arch\">[$curr_cnt]<\/span><\/li>/;
        }
        my($url_exist) = $c->menu->find( $table_archive_menu, 
                                         ['id'], 
                                         {'url' => $curr_url} 
                                       )->list;
        if(!$url_exist){
            $c->menu->create( $table_archive_menu, 
                              {'url' => $curr_url, menu => $common_menu} 
                            );
        }else{
            $c->menu->save( $table_archive_menu, 
                            {menu => $common_menu}, 
                            {'url' => $curr_url} 
                          );
        }
        $common_menu = $common_menu_orig;

    }

#return $common_menu;
}#-------------

#----------------------------------------
sub year_month {
#----------------------------------------
my($app, $self) = @_;
my $language = $self->language;
my $template = $self->template;
my $table_archive_menu = $self->top_config->{'table'}->{'archive_menu'};
my $table_rubric = $self->top_config->{'table'}->{'rubric'};
my $pagination_attr_file = $self->top_config->{'pagination_attr_file'};
my( %exist, %date_Data_hash, %date_Data_hash_mod, @title_alias, 
    $ref_pagination_attr, $tw_og, $limit_str, $message, @other_data, 
    @other_month, $current_page, $total_pages, $rubric, $i_begin, $i_end );
my $url = $self->req->url;
$url =~ s/\?page\=.*$//;
my $url_mod = $url;
my @url_components = split(/\//, $url);
my $year = $url_components[-2];
my $year_month_url = $year.'-'.$url_components[-1];
my $month = ucfirst( $self->lang_config->{'num_month'}->{$url_components[-1]}->{$language} );
my $title = $self->lang_config->{'labels'}->{$language}->{'archive'}.'. '.$month.' '.$url_components[-2];

my($description, $keywords) = $self->menu->find( 'level0', 
                                                 ['description', 'keywords'] 
                                               )->list;
( $ref_pagination_attr, $current_page, $limit_str ) = 
$self->routine_model->pagination_attr( $self, 'pagination_attr_file' );

@title_alias = @{TitleAliasList->title_alias_list_archive( $self )};

foreach my $curr_table( @title_alias ){    
    my $result = $self->db_table->arch_link_content( $self, $curr_table, $year_month_url );
    while( my $data = $result->hash ){
        if($data->{'rubric_id'} != 0){
        ($rubric) = $self->menu->find( $table_rubric, 
                                       ['rubric'], 
                                       {'id' => "$data->{'rubric_id'}"} 
                                      )->list;
        }
        $data->{'rubric'} = uc $rubric if $rubric;
        $data->{'children'} = $self->menu->find( $data->{'level'}, 
                                                 ['children'], 
                                                 {'id' => "$data->{'level_id'}"} 
                                               )->list;
        if( $data->{'children'} && $data->{'children'} eq 'yes' ){
            next;
        }
        $date_Data_hash{$data->{'curr_date'}} = $data;
    }
}

my($archive_menu) = $self->menu->find( $table_archive_menu, 
                                       ['menu'], 
                                       {'url' => $url} 
                                      )->list;

# Exception if no data or the month number is 0
if (!(keys %date_Data_hash) || $url_components[-1] eq '0' || !$archive_menu){
    return $self->render( template => 'not_found' );
}

$total_pages = int( (scalar keys %date_Data_hash)/$limit_str );
$total_pages = $total_pages + 1 if( (scalar keys %date_Data_hash)%$limit_str );

$i_begin = 1 if($current_page == 1);
$i_begin = ($current_page - 1) * $limit_str + 1;
$i_end = ($current_page - 1) * $limit_str + $limit_str;

# Generate data for the post '% date_Data_hash_mod' for the given month for the range '$i_begin .. $i_end',
my $i = 1;
foreach( reverse sort keys %date_Data_hash ){
    if($i < $i_begin){
        $i++; next;
    }
    if($i > $i_end || !$date_Data_hash{$_}){
        last;
    }
    $date_Data_hash_mod{$_} = $date_Data_hash{$_};
$i++;
}

foreach my $tbl(@title_alias){
    my $result = $self->db_table->yr_month( $self, $tbl, $year, $year_month_url );

        while( my $year_month = substr( $result->list, 0, 7 ) ){
            next if( $exist{$year_month} );
            push @other_month, $year_month;
            $exist{$year_month} = 1;
        }
}
EN:
my $menu = RewrMenu->active_rewrite( $self );
my( $ref_id_name_rubric, 
    $ref_rubr_id_count, 
    $exist_rubr_numb ) = RubricList->rubric_list($self);

$self->render(
template => lc($self->template).'/archive',
language => $language,
current_page => $current_page,
total_pages => $total_pages,
list_enable => 'yes',
pagination_attr => $ref_pagination_attr,
year_month => $month.' '.$url_components[-2],
menu => $menu,
content => {%date_Data_hash_mod},
description => $description.'. '.$title,
keywords => $keywords.'. '.$title,
other_month => [@other_month],
archive_menu => $archive_menu,
title => $title,
rubrics => $ref_id_name_rubric,
number_for_rubric => $ref_rubr_id_count,
exist_rubr_numb => $exist_rubr_numb
);
}#-------------
1;