# PDB parsing utilities 
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

package PDB_Parse ;

use strict ;

#############

select STDOUT ;
$| = 1 ;

##########################

my @correct_records ;
my @records ;
my @residue ;
my @stored_residue ;

my $altLoc ;
my $altloc_flag ;
my $atom ;
my $atom_name ;
my $atom_name_legal ;
my $atom_type_number ;
my $correct_sequence ;
my $chainID ;
my $chain_count ;
my $dir ;
my $i ;
my $iCode ;
my $legal_atom_name ;
my $legal_res_name ;
my $loc ;
my $multidock_flag ;
my $nc ;
my $occupancy ;
my $ok ;
my $olc ;
my $pdb_files_locations ;
my $pdb_id ;
my $pdbfile ;
my $previous_atom_name ;
my $previous_chainID ;
my $previous_iCode ;
my $previous_res_name ;
my $previous_res_seq ;
my $record ;
my $repeat ;
my $res_atom_count ;
my $res_name ;
my $res_name_legal ;
my $res_seq ;
my $residue_line ;
my $serial ;
my $stored_atom_name ;
my $stored_residue_line ;
my $tempFactor ;
my $use ;
my $warn ;
my $x ;
my $y ;
my $z ;

##########################
##########################

sub parse{

  #############
  #
  # What it does
  #
  # (1) chucks all residues that are not one of the twenty standard
  #      amino acids or one of the five standard nucleic acids
  #
  # (2) only keeps atoms it recognises as 'useful' - so chucks all
  #       Hydrogen atoms, and OXT 'cause its too iffy
  #
  # (3) chucks all but the first of an alternative atom indicator entry
  #
  # (4) checks for the correct number of atoms for that residue -
  #       if too many, then goes and checks for doubles of any atom type labels
  #       and chucks all but first ( ie some idiot forgot Alternate Indicator )
  #
  # (5) if still too many atoms for residue, then checks for atom type validity
  #
  # (6) if STILL to many - chucks that residue.  Does NOT chuck if too few
  #
  # (7) if MULTIDOCK_FLAG is on, then it DOES check for too few atoms, and tries
  #       to remodel residue as Alanine.  If still too few, DOES chuck.

  #############
  #
  # Initialise values

  $warn = shift @_ ;
  $multidock_flag = shift @_ ;
  @records = @_ ;
  @correct_records = () ;
  $correct_sequence = "" ;

  $altloc_flag = 0 ;
  $previous_atom_name = "xxxx" ;
  $previous_res_name = "xxx" ;
  $previous_chainID = 'xx' ;
  $previous_res_seq = 0.5 ;
  $previous_iCode = "x" ;

  $res_atom_count = 0 ;
  @residue = () ;

  $chain_count = 0 ;

  #############
  #
  # Loop

  foreach $record ( @records ) {

    if( $record =~ /^ATOM  / ) {

      if(
          ( $serial, $atom_name, $altLoc, $res_name, $chainID, $res_seq, $iCode ) =
          ( $record =~ /^ATOM  ([\ \d]{5})\ ([\ 1-9A-Z\*\']{4})(.)([\ A-Z]{3})\ ([\ A-Z0-9])([\ \-\d]{4})(.)\ \ \ [\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{3}\.\d{2}[\ \-\d]{3}\.\d{2}/ )
      ) {

        #############
        #
        # do this to chuck all new - and more likely non-standard (see eg 1jud) - columns

        $record = substr( $record , 0 , 66 ) ;
        $record = $record."\n" ;

        #############
        #
        # Check for legality of residue name ;

        $res_name_legal = 0 ;
        foreach $legal_res_name ( @PDB_Types::legal_res_names ) {
          if( $res_name eq $legal_res_name ) {
            $res_name_legal = 1 ;
            last ;
          }
        }
        if( $res_name_legal != 1 ) {
          if( $warn == 1 ){ printf( STDOUT "WARNING Residue name %3s is not recognised as legal / useful\n", $res_name ) ; }
#          next ;
        }

        #############
        #
        # Check for legality of atom name ;
  
        $atom_name_legal = 0 ;
        foreach $legal_atom_name ( @PDB_Types::legal_atom_names ) {
          if( $atom_name eq $legal_atom_name ) {
            $atom_name_legal = 1 ;
            last ;
          }
        }
        if( $atom_name_legal != 1 ) {
          if( $warn == 1 ){ printf( STDOUT "WARNING Atom name %5s is not recognised as legal / useful\n", $atom_name ) ; }
          next ;
        }
  
        #############
        #
        # Deal with Alternative Locations
  
        $altLoc =~ s/\ //g ;
  
        if(  ( length($altLoc) > 0 )  &&  ( $altloc_flag == 1 )  ) {
          if( $previous_atom_name eq $atom_name ) {
            if( $warn == 1 ){ printf( STDOUT "WARNING chucking an alternative location (atom serial number = %5d)\n", $serial ) ; }
            next ;
          } else {
            $altloc_flag = 0 ;
          }
        }
  
        if(  ( length($altLoc) > 0 )  &&  ( $altloc_flag == 0 )  ) {
          $altloc_flag = 1 ;
  
          #############
          #
          # change altLoc into a 'A' for consistency 
          # AND because STRIDE don't seem to like anything but 'A' or 'B'
          # in the AltLoc position ( not documented though )
  
          substr( $record , 16 , 1 ) = 'A' ;
  
          $previous_atom_name = $atom_name ;
        }

        if(  ( $altloc_flag == 1 )  && ( length($altLoc) == 0 )  ) {
          $previous_atom_name = "" ;
          $altloc_flag = 0 ;
        }
  
        #############
        #
        # check still in the same residue

        if( ($res_seq eq $previous_res_seq) && ($iCode eq $previous_iCode) ) {
          $res_atom_count ++ ;
        } else {

          #############
          #
          # End of the residue

          #############
          #
          # Don't want to do this for zeroth residue

          if( $res_atom_count > 0 ) {

            if( $PDB_Types::atoms_per_residue{$previous_res_name} ) {
              # have a legal ( == recognised ) residue here.  All ok
            } else {
              $previous_res_name = "XXX" ;
            }

            if( $res_atom_count > $PDB_Types::atoms_per_residue{$previous_res_name} ) {

              #############
              #
              # Problem - too many atoms for this residue type

              @residue = cope_with_excess( @residue ) ;

            }

            if( ( $res_atom_count < $PDB_Types::atoms_per_residue{$previous_res_name} ) && ( $multidock_flag == 1 ) ) {

              #############
              #
              # Problem for MULTIDOCK - too few atoms for this residue type - remodel as Alanine

              if( $warn == 1 ){ printf( STDOUT "WARNING residue %3s / %4d , has too few atoms " , $previous_res_name , $previous_res_seq ) ; }
              $res_atom_count = 0 ;
              my @alanine_modelled_residue = () ;

              foreach $residue_line ( @residue ) {

                ( $serial, $atom_name, $altLoc, $res_name, $res_seq, $iCode ) =
                ( $residue_line =~ /^ATOM  ([\ \d]{5})\ ([\ 1-9A-Z\*\']{4})(.)([\ A-Z]{3})\ [\ A-Z0-9]([\ \-\d]{4})(.)\ \ \ [\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{3}\.\d{2}[\ \-\d]{3}\.\d{2}/ ) ;

                if( ( $atom_name eq ' N  ' ) || ( $atom_name eq ' CA ' ) || ( $atom_name eq ' C  ' ) || ( $atom_name eq ' O  ' ) || ( $atom_name eq ' CB ' ) ) {

                  substr( $residue_line , 17 , 3 ) = 'ALA' ;
                  push( @alanine_modelled_residue , $residue_line ) ;
                  $res_atom_count ++ ;

                }

              }

              if( $res_atom_count == 5 ) {
                @residue = @alanine_modelled_residue ;
                if( $warn == 1 ){ printf( STDOUT "- modelled as Alanine succesfully!" ) } ;
              } else {
                @residue = () ;
                if( $warn == 1 ){ printf( STDOUT "- sorry - still problem - chucking" ) } ;
                printf( STDOUT "\nERROR WARNING :: Residue %3s / %4d has irredeemable problems - chucking!\n\n" , $res_name, $res_seq ) ;
              }
              if( $warn == 1 ){ printf( STDOUT "\n" ) ; }

            }

            #############
            #
            # Sort residue atoms into useful order

            @residue = sort sort_residue @residue ;
  
            #############
            #
            # all ok now - concatonate

            push( @correct_records , @residue ) ;

            if( defined( $residue[0] ) ) {
              if( $olc = $PDB_Types::one_letter_codes{substr( $residue[0] , 17 , 3 )} ) {
              } else {
                $olc = 'X' ;
              }
              $correct_sequence = $correct_sequence.$olc ;
            }

            #############
            #
            # End of chain check

            if( $previous_chainID ne $chainID ) {
              push( @correct_records , "TER\n" ) ;
              $chain_count ++ ;
            }

          } # end zeroth residue test

          #############
          #
          # Reset values for new residue

          $res_atom_count = 1 ;
          @residue = () ;
          $previous_chainID = $chainID ;

        }

        #############
        #
        # Reset values for next atom to be tested against

        ( $serial, $atom_name, $altLoc, $previous_res_name, $previous_res_seq, $previous_iCode ) =
          ( $record =~ /^ATOM  ([\ \d]{5})\ ([\ 1-9A-Z\*\']{4})(.)([\ A-Z]{3})\ [\ A-Z0-9]([\ \-\d]{4})(.)\ \ \ [\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{3}\.\d{2}[\ \-\d]{3}\.\d{2}/ ) ;

        #############
        #
        # Got this far without a 'last' chucking program onto next loop,
        # so concatonate record for this residue

        push( @residue , $record ) ;

      } else {
 
        #############
        #
        # Didn't pass original regexp test on ATOM record

        if( $warn == 1 ){ print STDOUT "WARNING - error in record format :: ".$record ; }

      } # end test if ATOM record is correct regexp

    } # end ATOM record test

  } # end @records

  #############
  #
  # End of the residue - since we are at end of @records

  if( $res_atom_count > $PDB_Types::atoms_per_residue{$previous_res_name} ) {

    #############
    #
    # Problem - too many atoms for this residue type

    @residue = cope_with_excess( @residue ) ;

  }

  if( ( $res_atom_count < $PDB_Types::atoms_per_residue{$previous_res_name} ) && ( $multidock_flag == 1 ) ) {

    #############
    #
    # Problem for MULTIDOCK - too few atoms for this residue type - remodel as Alanine

    if( $warn == 1 ){ printf( STDOUT "WARNING residue %3s / %4d , has too few atoms " , $previous_res_name , $previous_res_seq ) ; }
    $res_atom_count = 0 ;
    my @alanine_modelled_residue = () ;

    foreach $residue_line ( @residue ) {

      ( $serial, $atom_name, $altLoc, $res_name, $res_seq, $iCode ) =
      ( $residue_line =~ /^ATOM  ([\ \d]{5})\ ([\ 1-9A-Z\*\']{4})(.)([\ A-Z]{3})\ [\ A-Z0-9]([\ \-\d]{4})(.)\ \ \ [\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{3}\.\d{2}[\ \-\d]{3}\.\d{2}/ ) ;

      if( ( $atom_name eq ' N  ' ) || ( $atom_name eq ' CA ' ) || ( $atom_name eq ' C  ' ) || ( $atom_name eq ' O  ' ) || ( $atom_name eq ' CB ' ) ) {

        substr( $residue_line , 17 , 3 ) = 'ALA' ;
        push( @alanine_modelled_residue , $residue_line ) ;
        $res_atom_count ++ ;

      }

    }

    if( $res_atom_count == 5 ) {
      @residue = @alanine_modelled_residue ;
      if( $warn == 1 ){ printf( STDOUT "- modelled as Alanine succesfully!" ) } ;
    } else {
      @residue = () ;
      if( $warn == 1 ){ printf( STDOUT "- sorry - still problem - CHUCKING" ) } ;
    }
    if( $warn == 1 ){ printf( STDOUT "\n" ) ; }

  }

  #############
  #
  # Sort residue atoms into useful order

  @residue = sort sort_residue @residue ;

  #############
  #
  # all ok now - concatonate

  push( @correct_records , @residue ) ;
  if( defined( $residue[0] ) ) {
    if( $olc = $PDB_Types::one_letter_codes{substr( $residue[0] , 17 , 3 )} ) {
    } else {
      $olc = 'X' ;
    }
    $correct_sequence = $correct_sequence.$olc ;
  }

  push( @correct_records , "TER\n" ) ;
  $chain_count ++ ;

  #############
  #
  # Make last element of return the sequence (note to myself - this is not backward compatible!)

  push( @correct_records , $correct_sequence ) ;

  #############
  #
  # Finished

  printf( STDOUT "\nChains       :: %d\n\n" , $chain_count ) ;

  return @correct_records ;

} # end sub parse

##########################
##########################

sub cope_with_excess{

  @residue = @_ ;

  if( $warn == 1 ){ printf( STDOUT "WARNING residue %3s / %4d , has too many atoms " , $previous_res_name , $previous_res_seq ) ; }

  #############
  #
  # Check for repeat atom types which should have had AltLoc flags but obviously didn't

  if( $warn == 1 ){ printf( STDOUT "- missing AltLoc flags? ... " ) ; }

  $res_atom_count = 0 ;
  @stored_residue = () ;

  foreach $residue_line ( @residue ) {

    ( $serial, $atom_name, $altLoc, $res_name, $res_seq, $iCode ) =
    ( $residue_line =~ /^ATOM  ([\ \d]{5})\ ([\ 1-9A-Z\*\']{4})(.)([\ A-Z]{3})\ [\ A-Z0-9]([\ \-\d]{4})(.)\ \ \ [\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{3}\.\d{2}[\ \-\d]{3}\.\d{2}/ ) ;

    $repeat = 0 ;
    $i = -1 ;

    foreach $stored_residue_line ( @stored_residue ) {

      $i ++ ;
      ( $stored_atom_name ) = ( $stored_residue_line =~ /^ATOM  [\ \d]{5}\ ([\ 1-9A-Z\*\']{4})/ ) ;

      if( $stored_atom_name eq $atom_name ) {
        $repeat = 1 ;
        substr( $stored_residue[$i] , 16 , 1 ) = 'A' ;
        if( $warn == 1 ){ printf( STDOUT " found more than one %4s ..." , $atom_name ) ; }
      }

    }

    if( $repeat == 0 ) {

      push( @stored_residue , $residue_line ) ;
      $res_atom_count ++ ;

    } 
  }

  @residue = @stored_residue ;

  #############
  #
  # Check if ok now

  if( $PDB_Types::atoms_per_residue{$previous_res_name} >= $res_atom_count ) {

    if( $warn == 1 ){ printf( STDOUT " ... Seems to have been sorted.  Good!\n" ) ; }

  } else {

    if( $warn == 1 ){ printf( STDOUT " ... Still got problem" ) ; }

    #############
    #
    # Check for validity of atom names

    if( $warn == 1 ){ printf( STDOUT " - invalid atom types? ... " ) ; }

    $res_atom_count = 0 ;
    @stored_residue = () ;

    foreach $residue_line ( @residue ) {

      ( $serial, $atom_name, $altLoc, $res_name, $res_seq, $iCode ) =
      ( $residue_line =~ /^ATOM  ([\ \d]{5})\ ([\ 1-9A-Z\*\']{4})(.)([\ A-Z]{3})\ [\ A-Z0-9]([\ \-\d]{4})(.)\ \ \ [\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{4}\.\d{3}[\ \-\d]{3}\.\d{2}[\ \-\d]{3}\.\d{2}/ ) ;

      $atom_type_number = 0 ;

      $nc  = $PDB_Types::numerical_codes{$res_name} ;

      if(  ( ( $nc > 0 ) && ( $nc < 21 ) )  ||  ( ( $nc > 40 ) && ( $nc < 46 ) )  ) {

        if( $atom_type_number = $PDB_Types::atom_type_key[$nc]{$atom_name} ) {

          push( @stored_residue , $residue_line ) ;
          $res_atom_count ++ ;

        } else {

          if(  ( ( $nc > 0 )  &&  ( $nc < 21 ) )  &&  ( $warn == 1 )  ) {
            printf( STDOUT " found %4s - which is an invalid atom type for this residue ..." , $atom_name ) ;
          }

        }

      }

    }

    @residue = @stored_residue ;

    #############
    #
    # Check if ok now

    if( $PDB_Types::atoms_per_residue{$previous_res_name} >= $res_atom_count ) {

      if( $warn == 1 ){ printf( STDOUT " ... Seems to have been sorted.  Good!\n" ) ; }

    } else {

      if( $warn == 1 ){ printf( STDOUT " ... Still got problem - chucking!\n" ) ; }
      printf( STDOUT "\nERROR WARNING :: Residue %3s / %4d has irredeemable problems - chucking!\n\n" , $res_name, $res_seq ) ;

      @residue = () ;

    }

    #############

  }

  return @residue ;

  #############

} # end sub cope_with_excess

##########################
##########################

sub sort_residue{

  # order residue into useful order

  # Old version worse than useless DEFUNCT!!!!!!

  # my $atom_a ;
  # my $atom_b ;

  # ( $atom_a ) = substr( $a  , 12 , 4 ) ;
  # ( $atom_b ) = substr( $b  , 12 , 4 ) ;

  # my %atom_preferences ;

  # $atom_preferences{' CB '} = 1 ;
  # $atom_preferences{' CA '} = 2 ;
  # $atom_preferences{' C  '} = 3 ;
  # $atom_preferences{' N  '} = 4 ;
  # $atom_preferences{' O  '} = 5 ;

  # if( ! ( defined( $atom_preferences{$atom_a} ) ) ) { $atom_preferences{$atom_a} = 10 ; }
  # if( ! ( defined( $atom_preferences{$atom_b} ) ) ) { $atom_preferences{$atom_b} = 11 ; }

  # $atom_preferences{$atom_a} <=> $atom_preferences{$atom_b} ;

  # New version ensures atom record order correct

  my $atom_a ;
  my $atom_b ;

  ( $atom_a ) = substr( $a  , 6 , 5 ) ;
  ( $atom_b ) = substr( $b  , 6 , 5 ) ;

  $atom_a <=> $atom_b ;

}

##########################
##########################

sub add_types{

  #############
  #
  # Initialise values

  @records = @_ ;
  @correct_records = () ;

  #############
  #
  # Loop

  foreach $record ( @records ) {

    if( $record =~ /^ATOM  / ) {

      if(
          ( $serial, $atom_name, $altLoc, $res_name, $chainID, $res_seq, $iCode, $x, $y, $z, $occupancy, $tempFactor ) =
          ( $record =~ /^ATOM  ([\ \d]{5})\ ([\ 1-9A-Z\*\']{4})(.)([\ A-Z]{3})\ ([\ A-Z0-9])([\ \-\d]{4})([\ A-Z])\ \ \ ([\ \-\d]{4}\.\d{3})([\ \-\d]{4}\.\d{3})([\ \-\d]{4}\.\d{3})([\ \-\d]{3}\.\d{2})([\ \-\d]{3}\.\d{2})/ )
      ) {

        #############
        #
        # Add on information

        #############
        #
        # one letter codes and numerical codes

        if( $olc = $PDB_Types::one_letter_codes{$res_name} ) {
        } else {
          $olc = 'X' ;
        }

        if( $nc  = $PDB_Types::numerical_codes{$res_name} ) {
        } else {
          $nc = 0 ;
        }

        #############
        #
        # atom level pair potentials - atom type assignment

        if(  ( ( $nc > 0 ) && ( $nc < 21 ) )  ||  ( ( $nc > 40 ) && ( $nc < 46 ) )  ) {

          if(  ( $nc > 0 ) && ( $nc < 21 )  ) {

            if( $atom_type_number = $PDB_Types::atom_type_key[$nc]{$atom_name} ) {

              # extra info starts in 81st column
              $atom = sprintf( "ATOM  %5d %4s%1s%3s %1s%4s%1s   %8.3f%8.3f%8.3f%6.2f%6.2f              %1s %2d\n",
              $serial, $atom_name, $altLoc, $res_name, $chainID, $res_seq, $iCode, $x, $y, $z, $occupancy, $tempFactor,
              $olc, $nc ) ;

              push( @correct_records , $atom ) ;

            } else {

              if( $warn == 1 ){ printf( STDOUT "WARNING residue %3s / %4d , atom \:%4s\: has no type number - chucking\n" , $res_name , $res_seq , $atom_name ) ; }

            }

          } else {

              $atom_type_number = 0 ;
              # extra info starts in 81st column
              $atom = sprintf( "ATOM  %5d %4s%1s%3s %1s%4s%1s   %8.3f%8.3f%8.3f%6.2f%6.2f              %1s %2d\n" ,
              $serial, $atom_name, $altLoc, $res_name, $chainID, $res_seq, $iCode, $x, $y, $z, $occupancy, $tempFactor,
              $olc, $nc ) ;

              push( @correct_records , $atom ) ;

          }

        } else {

          # Cann't do much here but hope

          if( $warn == 1 ){ printf( STDOUT "WARNING Writing a non-legal residue [ %3s ] line\n" , $res_name ) ; }
 
          $atom_type_number = 0 ;

          $atom = sprintf( "ATOM  %5d %4s%1s%3s %1s%4s%1s   %8.3f%8.3f%8.3f%6.2f%6.2f              %1s %2d\n",
          $serial, $atom_name, $altLoc, $res_name, $chainID, $res_seq, $iCode, $x, $y, $z, $occupancy, $tempFactor,
          $olc, $nc ) ;

          push( @correct_records , $atom ) ;
        
        }

      } else {
 
        #############
        #
        # Didn't pass original regexp test on ATOM record

        print STDOUT "WARNING - error in record format :: ".$record ;

      } # end test if ATOM record is correct regexp

    } else { # end ATOM record test

      if( $record =~ /TER/ ) {

        push( @correct_records , $record ) ;

      }

    }

  } # end @records

  #############
  #
  # Finished

  return @correct_records ;

} # end sub add_types

1;
