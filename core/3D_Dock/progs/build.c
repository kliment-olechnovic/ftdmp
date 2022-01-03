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

  int		i , j ;

  int		residue_s , atom_s ;

  /* Command line options */

  char		*input_file_name ;
  int		b0 , b1	, b2 ;
  char		*gf_type ;
  char		gf_one_letter_code ;
  int		c_alpha ;

  /* File stuff */

  FILE		*ftdock_file ;
  char		line_buffer[100] ;

  char		*static_file_name ;
  char		*mobile_file_name ;
  char		*complex_file_name ;

  /* Structures */

  struct Structure	Static_Structure , Mobile_Structure ;
  struct Structure	Origin_Static_Structure , Origin_Mobile_Structure ;
  struct Structure	Rotated_at_Origin_Mobile_Structure , Translated_and_Rotated_at_Origin_Mobile_Structure ;
  struct Structure	Complex_Structure , C_Alpha_Complex_Structure ;

  /* Co-ordinates and Angles */

  int		x , y , z , z_twist , theta, phi ;

  /* Grid stuff */

  int		grid_size ;
  float		grid_span , one_span ;

  /* ftdock.dat file values */

  int		complex_id , prev_complex_id , SCscore ;
  float		RPscore ;

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


  printf( "Starting Build program\n" ) ;

/************/

  /* Memory allocation */

  if( ( ( input_file_name   = ( char * ) malloc ( 500 * sizeof( char ) ) ) == NULL ) ||
      ( ( gf_type           = ( char * ) malloc (  10 * sizeof( char ) ) ) == NULL ) ||
      ( ( static_file_name  = ( char * ) malloc ( 500 * sizeof( char ) ) ) == NULL ) ||
      ( ( mobile_file_name  = ( char * ) malloc ( 500 * sizeof( char ) ) ) == NULL ) ||
      ( ( complex_file_name = ( char * ) malloc ( 500 * sizeof( char ) ) ) == NULL ) ) {
    GENERAL_MEMORY_PROBLEM
  }

/************/

  /* Command Line defaults */

  strcpy( input_file_name , "ftdock_rpscored.dat" ) ;
  b0 = 0 ;
  b1 = 1 ;
  b2 = NUMBER_TO_KEEP ;
  strcpy( gf_type , "G_DATA" ) ;
  gf_one_letter_code = 'g' ;
  c_alpha = 0 ;

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
      if( strcmp( argv[i] , "-b0" ) == 0 ) {
        i ++ ;
        if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
          printf( "Bad command line\n" ) ;
          exit( EXIT_FAILURE ) ;
        }
        sscanf( argv[i] , "%d" , &b0 ) ;
      } else {
        if( strcmp( argv[i] , "-b1" ) == 0 ) {
          i ++ ;
          if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
            printf( "Bad command line\n" ) ;
            exit( EXIT_FAILURE ) ;
          }
          sscanf( argv[i] , "%d" , &b1 ) ;
        } else {
          if( strcmp( argv[i] , "-b2" ) == 0 ) {
            i ++ ;
            if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
              printf( "Bad command line\n" ) ;
              exit( EXIT_FAILURE ) ;
            }
            sscanf( argv[i] , "%d" , &b2 ) ;
          } else {
            if( strcmp( argv[i] , "-fine" ) == 0 ) {
              strcpy( gf_type , "F_DATA" ) ;
              gf_one_letter_code = 'f' ;
            } else {
              if( strcmp( argv[i] , "-c_alpha" ) == 0 ) {
                c_alpha = 1 ;
              } else {
                printf( "Bad command line\n" ) ;
                exit( EXIT_FAILURE ) ;
              }
            }
          }
        }
      }
    }

  }

/************/

  /* Read neat data file - headers */

  if( ( ftdock_file = fopen( input_file_name , "r" ) ) == NULL ) {
    printf( "Could not open %s for reading.\nDying\n\n" , input_file_name ) ;
    exit( EXIT_FAILURE ) ;
  }

  while( fgets( line_buffer, 99, ftdock_file ) ) {

    if( strncmp( line_buffer , "Static molecule" , 15 ) == 0 ) sscanf( line_buffer , "Static molecule :: %s" , static_file_name ) ;

    if( strncmp( line_buffer , "Mobile molecule" , 15 ) == 0 ) sscanf( line_buffer , "Mobile molecule :: %s" , mobile_file_name ) ;

    if( gf_one_letter_code == 'g' ) {

      if( strncmp( line_buffer , "Global grid size" , 16 ) == 0 ) sscanf( line_buffer , "Global grid size :: %d" , &grid_size ) ;

    } else {

      if( strncmp( line_buffer , "Refinement grid size" , 20 ) == 0 ) sscanf( line_buffer , "Refinement grid size :: %d" , &grid_size ) ;

    }

    if( strncmp( line_buffer , gf_type , 6 ) == 0 ) break ;

  }

  fclose( ftdock_file ) ;

/************/

  /* Read in Structures from pdb files */
  Static_Structure = read_pdb_to_structure( static_file_name ) ;
  Mobile_Structure = read_pdb_to_structure( mobile_file_name ) ;

/************/

  /* Store new structures centered on Origin */

  Origin_Static_Structure = translate_structure_onto_origin( Static_Structure ) ;
  Origin_Mobile_Structure = translate_structure_onto_origin( Mobile_Structure ) ;

  /* Free some memory */

  for( i = 1 ; i <= Static_Structure.length ; i ++ ) {
    free( Static_Structure.Residue[i].Atom ) ;
  }
  free( Static_Structure.Residue ) ;

  for( i = 1 ; i <= Mobile_Structure.length ; i ++ ) {
    free( Mobile_Structure.Residue[i].Atom ) ;
  }
  free( Mobile_Structure.Residue ) ;

/************/

  /* Calculate Grid stuff */

  grid_span = total_span_of_structures( Origin_Static_Structure , Origin_Mobile_Structure ) ;

  one_span = grid_span / (float)grid_size ;

/************/

  /* Reopen ftdock.dat */

  if( ( ftdock_file = fopen( input_file_name , "r" ) ) == NULL ) {
    printf( "Could not open %s for reading.\nDying\n\n" , input_file_name ) ;
    exit( EXIT_FAILURE ) ;
  }

/************/

  /* Choose between range to build or specific individual */

  if( b0 != 0 ) {

    /* Build individual */

    printf( "Building complex %s %d only\n" , gf_type , b0 ) ;

    b1 = b0 ;
    b2 = b0 ;

  } else {

    /* Build range */

    printf( "Building complexes %s %d -> %d\n" , gf_type , b1 , b2 ) ;

  }

  /* Build */

  while( fgets( line_buffer, 99, ftdock_file ) ) {

    for( i = b1 ; i <= b2 ; i ++ ) {

      if( strncmp( line_buffer , gf_type , 6 ) == 0 ) {

        sscanf( line_buffer + 1 , "_DATA %d %d %d %f  %d %d %d  %d %d %d" , &complex_id , &prev_complex_id , &SCscore , &RPscore , &x , &y , &z , &z_twist , &theta , &phi ) ;

        if( complex_id == i ) {

          /* Rotate Mobile Structure */
          Rotated_at_Origin_Mobile_Structure = rotate_structure( Origin_Mobile_Structure , z_twist , theta , phi ) ;
         
          /* Translate Mobile Structure */
          Translated_and_Rotated_at_Origin_Mobile_Structure = translate_structure( Rotated_at_Origin_Mobile_Structure , (float)x * one_span , (float)y * one_span , (float)z * one_span ) ;
         
          /************/

          /* Write Complex */

          Complex_Structure = merge_structures( Origin_Static_Structure , Translated_and_Rotated_at_Origin_Mobile_Structure ) ;

          sprintf( complex_file_name , "Complex_%d%c.pdb" , complex_id , gf_one_letter_code ) ;

          /************/

          if( c_alpha == 1 ) {

            if( ( C_Alpha_Complex_Structure.Residue = ( struct Amino_Acid * ) malloc ( ( Complex_Structure.length + 1 ) * sizeof_Amino_Acid ) ) == NULL ) {
              GENERAL_MEMORY_PROBLEM
            }

            strcpy( C_Alpha_Complex_Structure.ident , Complex_Structure.ident ) ;
            C_Alpha_Complex_Structure.length = Complex_Structure.length ;

            for( residue_s = 1 ; residue_s <= Complex_Structure.length ; residue_s ++ ) {
          
              C_Alpha_Complex_Structure.Residue[residue_s] = Complex_Structure.Residue[residue_s] ;
              C_Alpha_Complex_Structure.Residue[residue_s].size = 1 ;
          
              if( ( C_Alpha_Complex_Structure.Residue[residue_s].Atom = ( struct Atom * ) malloc ( 2 * sizeof_Atom ) ) == NULL ) {
                GENERAL_MEMORY_PROBLEM
              }
          
              for( atom_s = 1 ; atom_s <= Complex_Structure.Residue[residue_s].size ; atom_s ++ ) {
          
                if( strcmp( Complex_Structure.Residue[residue_s].Atom[atom_s].atom_name , " CA " ) == 0 ) {
                  C_Alpha_Complex_Structure.Residue[residue_s].Atom[1] = Complex_Structure.Residue[residue_s].Atom[atom_s] ;
                }
          
              }

            }

            sprintf( complex_file_name , "CA_Complex_%d%c.pdb" , complex_id , gf_one_letter_code ) ;

            write_structure_to_pdb( C_Alpha_Complex_Structure , complex_file_name ) ;

          } else {

            write_structure_to_pdb( Complex_Structure , complex_file_name ) ;

          }

          /************/

          /* Free some memory */
          for( j = 1 ; j <= Rotated_at_Origin_Mobile_Structure.length ; j ++ ) {
            free( Rotated_at_Origin_Mobile_Structure.Residue[j].Atom ) ;
            free( Translated_and_Rotated_at_Origin_Mobile_Structure.Residue[j].Atom ) ;
          }
          free( Rotated_at_Origin_Mobile_Structure.Residue ) ;
          free( Translated_and_Rotated_at_Origin_Mobile_Structure.Residue ) ;
          for( j = 1 ; j <= Complex_Structure.length ; j ++ ) {
            free( Complex_Structure.Residue[j].Atom ) ;
          }
          free( Complex_Structure.Residue ) ;

        }

      }

    }

  }


/************/

  /* Free the memory */

  for( i = 1 ; i <= Origin_Static_Structure.length ; i ++ ) {
    free( Origin_Static_Structure.Residue[i].Atom ) ;
  }
  free( Origin_Static_Structure.Residue ) ;

  for( i = 1 ; i <= Origin_Mobile_Structure.length ; i ++ ) {
    free( Origin_Mobile_Structure.Residue[i].Atom ) ;
  }
  free( Origin_Mobile_Structure.Residue ) ;

/************/

  printf( "Finished\n\n" ) ;

  return( 0 ) ;

} /* end main */
