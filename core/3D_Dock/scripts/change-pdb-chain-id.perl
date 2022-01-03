#!/usr/bin/perl -w

# use to change a chain ID in a pdb file
# Copyright (C) 1997-2000 Gidon Moont
# 
# Biomolecular Modelling Laboratory
# Imperial Cancer Research Fund
# 44 Lincoln's Inn Fields
# London WC2A 3PX
# 
# +44 (0)20 7269 3348
# http://www.bmm.icnet.uk/
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
# 
# #############
# 
# ensure messages appear asap

select STDOUT ;
$| = 1 ;

#############
#
# Command line options

$pdb_file  = 'undefined' ;
$original  = 'undefined' ;
$change_to = 'undefined' ;

while( @ARGV ) {

  $bit = shift @ARGV ;

  if( $bit eq '-pdb' ) {
    $pdb_file = shift @ARGV ;
  }

  if( $bit eq '-old' ) {
    $original = shift @ARGV ;
  }

  if( $bit eq '-new' ) {
    $change_to = shift @ARGV ;
  }

}

#############
#
# Screen notices

print STDOUT "\nRunning $0 ...\n" ;

print STDOUT "pdb          :: ".$pdb_file."\n" ;
print STDOUT "old          :: ".$original."\n" ;
print STDOUT "new          :: ".$change_to."\n" ;

#############
#
# Do it!

open( PDB_IN , $pdb_file ) || die "Could not open file\n" ;
open( PDB_OUT , "> temp_changed_chain_id.pdb" ) || die "Could not open file\n" ;

while( <PDB_IN> ) {

  if( ( $_ =~ /^ATOM/ ) && ( substr( $_ , 21 , 1 ) eq $original ) ) {

    substr( $_ , 21 , 1 ) = $change_to ;

  }

  print PDB_OUT $_ ;

}

close( PDB_IN ) ;
close( PDB_OUT ) ;

system "mv temp_changed_chain_id.pdb $pdb_file" ;

#############
#
# Finished

exit ;
