package MyBlog::Plugin::BootstrapPgn;
use Mojo::Base 'Mojolicious::Plugin';
use POSIX( qw/ceil/ );
use Mojo::ByteStream 'b';

use strict;
use warnings;

sub  register{
  my ( $self, $app, $args ) = @_;
  $args ||= {};

  $app->helper( bootstrap_pgn => sub{
      my ( $self, $actual, $count, $opts ) = @_;

      my $localize = ( $opts->{localize} || $args->{localize} ) ?
          ( $opts->{localize} || $args->{localize} ) : undef;

      $count = ceil($count);
      return "" unless $count > 1;
      $opts = {} unless $opts;
      my $round = $opts->{round} || $args->{round} || 4;
      my $param = $opts->{param} || $args->{param} || "page";
      my $class = $opts->{class} || $args->{class} || "";
      if ($class ne ""){
          $class = " " . $class;
      }
      my $outer = $opts->{outer} || $args->{outer} || 2;
      my $query = exists $opts->{query} ? $opts->{query} : $args->{query} || "";
      my $start = $opts->{start} // $args->{start} // 1;
      my @current = ( $actual - $round .. $actual + $round );
      my @first   = ($start.. $start + $outer - 1);
      my @tail    = ( $count - $outer + 1 .. $count );
      my @ret = ();
      my $last = undef;
      foreach my $number( sort { $a <=> $b } @current, @first, @tail ){
        next if ( $last && $last == $number && $start > 0 ) || ( defined $last && $last == $number && $start == 0 );
        next if ( $number <= 0 && $start > 0) || ( $number < 0 && $start == 0 );
        last if ( $number > $count && $start > 0 ) || ( $number >= $count && $start == 0 );
        push @ret, ".." if( $last && $last + 1 != $number );
        push @ret, $number;
        $last = $number;
      }

      my $html = "<ul class=\"pagination$class\">";
      if( $actual == $start || $actual < 0 ){
        $html .= "<li class=\"disabled\"><a href=\"#\" >&laquo;</a></li>";
      } else {
        $html .= "<li><a href=\"" . $self->url_for->query( [$param => $actual - 1] ) . $query . "\" >&laquo;</a></li>";
      }
      my $last_num = -1;
      foreach my $number( @ret ){
        my $show_number = $start > 0 ? $number : ( $number =~ /\d+/ ? $number + 1 : $number );

        if ( $localize ) {
            $show_number = $localize->($self, $show_number);
        }

        if( $number eq ".." && $last_num < $actual ){
          my $offset = ceil( ( $actual - $round ) / 2 ) + 1 ;
          $html .= "<li><a href=\"" . $self->url_for->query( [$param => $start == 0 ? $offset + 1 : $offset] ) . $query ."\" >&hellip;</a></li>";
        }
        elsif( $number eq ".." && $last_num > $actual ) {
          my $back = $count - $outer + 1;
          my $forw = $round + $actual;
          my $offset = ceil( ( ( $back - $forw ) / 2 ) + $forw );
          $html .= "<li><a href=\"" . $self->url_for->query( [$param => $start == 0 ? $offset + 1 : $offset] ) . $query ."\" >&hellip;</a></li>";
        } elsif( $number == $actual ) {
          $html .= "<li class=\"active\"><span>$show_number</span></li>";
        } else {
          $html .= "<li><a href=\"" . $self->url_for->query( [$param => $number] ) . $query ."\">$show_number</a></li>";
        }
         $last_num = $number;
      }
      if( $actual == $count ){
        #$html .= "<li class=\"disabled\"><a href=\"" . $self->url_for->query( [$param => $actual + 1] ) . $query . "\" >&raquo;</a></li>";
        $html .= "<li class=\"disabled\"><a href=\"#\" >&raquo;</a></li>";
      } else {
        $html .= "<li><a href=\"" . $self->url_for->query( [$param => $actual + 1] ) . $query . "\" >&raquo;</a></li>";
      }
      $html .= "</ul>";
      return b( $html );
    } );

}
1;