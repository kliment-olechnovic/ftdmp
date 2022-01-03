/*
This file is part of ftdock, a program for rigid-body protein-protein docking 
Copyright (C) 1997-2000 Gidon Moont

Biomolecular Modelling Laboratory
Imperial Cancer Research Fund
44 Lincoln's Inn Fields
London WC2A 3PX

+44 (0)20 7269 3348
http://www.bmm.icnet.uk/

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

*/

#include "structures.h"

int main( int argc , char *argv[] ) {

  /* index counters */

  int	i ;

  /* Command line options */

  char	input_file_name[1024] ;
  char	output_file_name[1024] ;

  /* Angles stuff */

  int	z_twist , theta , phi ;

  /* Structures */

  struct Structure	Input_Structure , Origin_Structure , Spun_Structure ;

/************/

  /* Its nice to tell people what going on straight away */

  setvbuf( stdout , (char *)NULL , _IONBF , 0 ) ;


  printf( "\n          3D-Dock Suite (March 2001)\n" ) ;
  printf( "          Copyright (C) 1997-2000 Gidon Moont\n" ) ;
  printf( "          This program comes with ABSOLUTELY NO WARRANTY\n" ) ;
  printf( "          for details see license. This program is free software,\n"); 
  printf( "          and you may redistribute it under certain conditions.\n\n"); 

  printf( "          Biomolecular Modelling Laboratory\n" ) ;
  printf( "          Imperial Cancer Research Fund\n" ) ;
  printf( "          44 Lincoln's Inn Fields\n" ) ;
  printf( "          London WC2A 3PX\n" ) ;
  printf( "          +44 (0)20 7269 3348\n" ) ;
  printf( "          http://www.bmm.icnet.uk/\n\n" ) ;

/************/

  printf( "Starting FTDock random spin program (FTDock v2.0)\n" ) ;

/************/

  /* Command Line defaults */

  strcpy( input_file_name , "unspun.pdb" ) ;
  strcpy( output_file_name , "spun.pdb" ) ;

  /* Command Line parse */

  for( i = 1 ; i < argc ; i ++ ) {

    if( strcmp( argv[i] , "-in" ) == 0 ) {
      i ++ ;
      if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
        printf( "Bad command line\n" ) ;
        exit( EXIT_FAILURE ) ;
      }
      strcpy( input_file_name , argv[i] ) ;
    } else {
      if( strcmp( argv[i] , "-out" ) == 0 ) {
        i ++ ;
        if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
          printf( "Bad command line\n" ) ;
          exit( EXIT_FAILURE ) ;
        }
        strcpy( output_file_name , argv[i] ) ;
      } else {
        printf( "Bad command line\n" ) ;
        exit( EXIT_FAILURE ) ;
      }
    }

  }

/************/

  /* Read in Structure from pdb file */
  Input_Structure = read_pdb_to_structure( input_file_name ) ;

  /* Store new structures centered on Origin */
  Origin_Structure = translate_structure_onto_origin( Input_Structure ) ;

  /* Free some memory */
  for( i = 1 ; i <= Input_Structure.length ; i ++ ) {
    free( Input_Structure.Residue[i].Atom ) ;
  }
  free( Input_Structure.Residue ) ;

  /* Spin Structure */
  for( i = 0 ; i < 10 ; i ++ ) {

    /* Get angles */
    srand( (unsigned int)time( NULL ) ) ;
    z_twist = (int)( 359 * ( (float)rand() / (float)RAND_MAX ) ) ;
    theta   = (int)( 179 * ( (float)rand() / (float)RAND_MAX ) ) ;
    phi     = (int)( 359 * ( (float)rand() / (float)RAND_MAX ) ) ;

    Spun_Structure = rotate_structure( Origin_Structure , (long int)z_twist , (long int)theta , (long int)phi ) ;

    for( i = 1 ; i <= Origin_Structure.length ; i ++ ) {
      free( Origin_Structure.Residue[i].Atom ) ;
    }
    free( Origin_Structure.Residue ) ;

    if( i != 9 ) Origin_Structure = duplicate_structure( Spun_Structure ) ;

  }

  write_structure_to_pdb( Spun_Structure , output_file_name ) ;

  for( i = 1 ; i <= Spun_Structure.length ; i ++ ) {
    free( Spun_Structure.Residue[i].Atom ) ;
  }
  free( Spun_Structure.Residue ) ;

/************/

  printf( "\n\nFinished\n\n" ) ;

  return( 0 ) ;

} /* end main */
