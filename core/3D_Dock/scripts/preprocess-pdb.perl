#!/usr/bin/perl -w

# Parse PDB molecule
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

use strict ;

my $sys_com ;
my $record ;
my $i ;
my $j ;
my $info ;

#############
#
# ensure messages appear asap

select STDOUT ;
$| = 1 ;

#############
#
# Other programs and files used by this one

BEGIN{

  my $full_program_name = $0 ;
  my $relative_path ;
  ( $relative_path ) = ( $full_program_name =~ /^(.+)\/.+$/ ) ;

  unshift( @INC , ( "$relative_path" ) ) ;

}

use PDB_Types ;
use PDB_Parse ;

print STDERR "$ARGV[0] : $ARGV[1]\n" ;

#############
#
# Command line options

my $pdb_file = 'undefined' ;
my $warn = 1 ;
my $multidock_flag = 0 ;

while( @ARGV ) {

  my $bit = shift @ARGV ;

  if( $bit eq '-nowarn' ) {
    $warn = 0 ;
  }

  if( $bit eq '-multidock' ) {
    $multidock_flag = 1 ;
  }

  if( $bit eq '-pdb' ) {
    $pdb_file = shift @ARGV ;
  }

}

#############
#
# Screen notices

my $full_program_name = $0 ;
my $program_name ;
( $program_name ) = ( $full_program_name =~ /^.+\/(.+)$/ ) ;

print STDOUT "\nRunning $program_name ...\n" ;

print STDOUT "pdb file     :: ".$pdb_file."\n" ;
print STDOUT "warn         :: ".$warn."\n" ;
print STDOUT "multidock    :: ".$multidock_flag."\n" ;

print STDOUT "\n" ;

#############
#
# Get ATOM records

my @atomrecords = () ;
open( PDB_File , $pdb_file ) || die "Could not open molecule file\n" ;
while( defined( $record = <PDB_File> ) ) {
  if( $record =~ /^ATOM  / ) {
    push( @atomrecords , $record ) ;
  }
}
close( PDB_File ) ;

#############
#
# Parse

my @correct_records = PDB_Parse::parse( $warn , $multidock_flag , @atomrecords ) ;

my $correct_sequence = pop @correct_records ;

if( $multidock_flag == 0 ) {
  @correct_records = PDB_Parse::add_types( @correct_records ) ;
}

#############
#
# Fasta style file dump

my $name ;

( $name ) = ( $pdb_file =~ /^(.+)\..+/ ) ;

open( Dump , "> ".$name.".fasta" ) || die "Could not open for writing\n" ;
print Dump "> ".$name."\n" ;
print Dump $correct_sequence ;
close( Dump ) ;

#############
#
# PDB style file dump

open( Dump , "> ".$name.".parsed" ) || die "Could not open for writing\n" ;
print Dump @correct_records ;
close( Dump ) ;

#############
#
# Finished

exit ;
