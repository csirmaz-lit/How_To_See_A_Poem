#!/usr/bin/perl

# Script to automatically generate TOC and navigation links

use strict;

my $path = '../How_To_See_A_Poem.wiki';

my @files = split(/\s/, `find $path -name "Book-???-*.wiki" -printf "%f\n"`);
foreach my $f (@files){ $f =~ s/^\s+|\s+$//g; }
@files = sort(@files);

# Get the internal filenames
my %wikiname;
foreach my $f (@files){
  $f =~ /^(.*)\.wiki$/;
  $wikiname{$f} = $1;
  $wikiname{$f} =~ s/-/ /g;
}

my $contents1 = shift(@files);
my $contents = $path.'/'.$contents1;

# Get the titles
my %titles;
foreach my $f (@files){
  $titles{$f} = `grep -m 1 -P '^=.*=\$' $path/$f`;
  $titles{$f} =~ s/^=+|=+\s*$//g;
}

# Create the TOC
my $c;
open FILE, $contents;
while(<FILE>){
  $c .= $_;
  if(/^==Contents==/){ last; }
}
close FILE;

$c .= "\n";
foreach my $f (@files){
  $c .= '* [['.$wikiname{$f}.'|'.$titles{$f}."]]\n";
}

open FILE, '>'.$contents;
print FILE $c;
close FILE;

# Create navigation links

for(my $i=0; $i<@files; $i++){

  my ($pnav, $nnav, $cnav);
  $pnav = '[['.$wikiname{$files[$i-1]}.'|<img src="images/arrow_left.png"/> Previous: '.$titles{$files[$i-1]}."]] / \n" if $i>0;
  $nnav = '[['.$wikiname{$files[$i+1]}.'|<img src="images/arrow_right.png"/> Next: '.$titles{$files[$i+1]}."]] / \n" if $i<@files-1;
  $cnav = '[['.$wikiname{$contents1}.'|<img src="images/bookmark_book.png"/> Contents'."]]\n";

  my $f = $path.'/'.$files[$i];
  open FILE, $f;
  $c = '';
  my $preadded;
  my $postadded;
  while(<FILE>){
    if((!$preadded) && (/^=/ || /^----/)){
       $c .= $pnav . $nnav . $cnav;
       if(/^=/){ $c .= "----\n"; }
       $preadded = 1;
    }
    if($preadded){
      if(/> (Previous|Next|Contents)/){
        $c .= $nnav . $pnav . $cnav;
        $postadded = 1;
        last;
      }
      $c .= $_;
    }
  }
  close FILE;
  
  unless($postadded){
    $c .= "----\n" . $nnav . $pnav . $cnav;
  }
  
  open FILE, '>'.$f;
  print FILE $c;
  close FILE;  
}

