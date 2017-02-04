use warnings;
use strict;
use utf8;

use File::Find;
use File::Spec;
use open ':encoding(utf8)';

my %found;


my $out_page = 'Waehrungsreform';

find(sub {

    return if -d;

    return if /\@tmpl=/;

    my $rel_path = File::Spec -> abs2rel($File::Find::name, $File::Find::topdir);
    $rel_path =~ s!\\!/!g;

    open (my $f, '<', $_) or die "could not open $_";
    my $date;
    while (my $in = <$f>) {


      if ($in =~ m!<span class="cdate">(\d\d\d\d-\d\d-\d\d):.*</span>!) {
        $date = $1;
      }
      elsif ($in =~ m!Neu (\d\d\d\d-\d\d-\d\d)!) {
        $date = $1;
      }


      $in =~ s/<[^>]*>//g;

      if ($out_page eq 'Waehrungsreform') {


        if ($in =~ s!Währungsreform\w*!<b>$&</b>!g) {

          my $changes=0;

          if ($in =~ s!Nordkorea!<b>$&</b>!g) {
            $changes ++;
          }
          if ($in =~ s!kommt sicher!<b>$&</b>!g) {
            $changes ++;
          }
          if ($in =~ s!(absolut )?sicher\w* Zeichen!<b>$&</b>!g) {
            $changes ++;
          }
          if ($in =~ s!\bam.{1,20}kommt!<b>$&</b>!g) {
            $changes ++;
          }
          if ($in =~ s!Insider-?Info\w*!<b>$&</b>!g) {
            $changes ++;
          }
          if ($in =~ s!kommt (diese\w*|nächst\w*) (Jahr|Monat|Wochenend\w*)!<b>$&</b>!g) {
            $changes ++;
          }

          if ($changes) {
            push @{$found{$date}{$rel_path}}, $in;
          }
        }

#       if ($in =~ s!kommt.*?jetzt.*?\bbald!<b>$&</b>!g) { 
#         push @{$found{$date}{$rel_path}}, $in;
#       }
      }


    }

  },
  'F:\Digitales-Backup\Misc\hardgeld\hartgeld.com\service\archiv'
);

open (my $out, '>', "c:/temp/hartgeld/$out_page.html") or die;

print $out '<!DOCTYPE html>
<html><head>

<style>

  * {
    font-family: Arial;
  }
  body {

    margin-left: 100px;
    width: 600px;

  }

/*.date {
    color: blue;
    font-weight: bold;
  } */
  a {
    font-weight: bold;
    color: blue;
  }
  b {
    color: red;
  }

</style>

  <meta http-equiv="Content-Type" content="text/html; charset=utf-8">
<head><body>
';

for my $date (sort keys %found) {

# print $out "<div class='date'>$date:</div>";

  for my $page (keys %{$found{$date}}) {
    print $out "<a href='https://hartgeld.com/service/archiv/$page'>$date</a>\n";

    for my $sentence (@{$found{$date}{$page}}) {
      print $out "$sentence<p>";
    }

  }

}

print $out '</body></html>';
close $out;

