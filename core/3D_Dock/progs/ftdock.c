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

  /* index counters and other utility variables */

  int	i ;
  int	j ;
  int   case_found ;

  /* Command line options */

  char		*output_file_name ;
  char		*static_file_name ;
  char		*mobile_file_name ;
  int		global_grid_size ;
  int		angle_step ;
  float		surface ;
  float		internal_value ;
  int		electrostatics ;
  int		keep_per_rotation ;
  int 		kept_scores ;
  int		rescue ;
  int		calculate ;
  float		reverse_calculated_one_span ;

  int		parallel_parts ;
  int		parallel_id ;
  int       reduce_translations ;

  char		*default_global_grid_size ;
  char		*default_angle_step ;
  char		*default_surface ;
  char		*default_internal_value ;
  char		*default_electrostatics ;
  char		*default_keep_per_rotation ;

  /* File stuff */

  FILE		*ftdock_file ;
  char		line_buffer[100] ;
  int		id , id2 , SCscore ;
  float		RPscore ;
  int		x , y , z , z_twist , theta , phi ;

  /* Angles stuff */

  struct Angle	Angles ;
  int		first_rotation , rotation ;

  /* Structures */

  struct Structure	Static_Structure , Mobile_Structure ;
  struct Structure	Origin_Static_Structure , Origin_Mobile_Structure ;
  struct Structure	Rotated_at_Origin_Mobile_Structure ;

  /* Co-ordinates */

  int		xyz , fx , fy , fz , fxyz ;

  /* Grid stuff */

  float		grid_span , one_span ;

  fftw_real	*static_grid ;
  fftw_real	*mobile_grid ;
  fftw_real	*convoluted_grid ;

  fftw_real	*static_elec_grid = ( void * ) 0 ;
  fftw_real	*mobile_elec_grid = ( void * ) 0 ;
  fftw_real	*convoluted_elec_grid = ( void * ) 0 ;

  /* FFTW stuff */

  rfftwnd_plan	p , pinv ;

  fftw_complex  *static_fsg ;
  fftw_complex  *mobile_fsg ;
  fftw_complex  *multiple_fsg ;

  fftw_complex  *static_elec_fsg = ( void * ) 0 ;
  fftw_complex  *mobile_elec_fsg = ( void * ) 0 ;
  fftw_complex  *multiple_elec_fsg = ( void * ) 0 ;

  /* Scores */

  struct Score	*Scores ;
  float		max_es_value ;

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


  printf( "Starting FTDock (v2.0) global search program\n" ) ;


/************/

  /* Memory allocation */

  if( ( ( output_file_name  = ( char * ) malloc ( 500 * sizeof( char ) ) ) == NULL ) ||
      ( ( static_file_name  = ( char * ) malloc ( 500 * sizeof( char ) ) ) == NULL ) ||
      ( ( mobile_file_name  = ( char * ) malloc ( 500 * sizeof( char ) ) ) == NULL ) ) {
    GENERAL_MEMORY_PROBLEM 
  }

/************/

  /* Command Line defaults */

  strcpy( output_file_name , "ftdock_global.dat" ) ;
  strcpy( static_file_name , " --static file name was not provided--" ) ;
  strcpy( mobile_file_name , " --mobile file name was not provided--" ) ;
  global_grid_size = 128 ;
  angle_step = 12 ;
  surface = 1.3 ;
  internal_value = -15 ;
  electrostatics = 1 ;
  keep_per_rotation = 3 ;
  rescue = 0 ;
  calculate = 1 ;
  reverse_calculated_one_span = 0.7 ;

  parallel_parts = 1 ;
  parallel_id = 1 ;
  reduce_translations = 0 ;

  default_global_grid_size = "(default calculated)" ;
  default_angle_step = "(default)" ;
  default_surface = "(default)" ;
  default_internal_value = "(default)" ;
  default_electrostatics = "(default)" ;
  default_keep_per_rotation = "(default)" ;

  /* Command Line parse */

  for( i = 1 ; i < argc ; i ++ ) {

    if( strcmp( argv[i] , "-out" ) == 0 ) {
      i ++ ;
      if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
        printf( "Bad command line\n" ) ;
        exit( EXIT_FAILURE ) ;
      }
      strcpy( output_file_name , argv[i] ) ;
    } else {
      if( strcmp( argv[i] , "-static" ) == 0 ) {
        i ++ ;
        if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
          printf( "Bad command line\n" ) ;
          exit( EXIT_FAILURE ) ;
        }
        strcpy( static_file_name , argv[i] ) ;
      } else {
        if( strcmp( argv[i] , "-mobile" ) == 0 ) {
          i ++ ;
          if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
            printf( "Bad command line\n" ) ;
            exit( EXIT_FAILURE ) ;
          }
          strcpy( mobile_file_name , argv[i] ) ;
        } else {
          if( strcmp( argv[i] , "-grid" ) == 0 ) {
            i ++ ;
            if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
              printf( "Bad command line\n" ) ;
              exit( EXIT_FAILURE ) ;
            }
            sscanf( argv[i] , "%d" , &global_grid_size ) ;
            if( ( global_grid_size % 2 ) != 0 ) {
              printf( "Grid size must be even\n" ) ;
              exit( EXIT_FAILURE ) ;
            }
            default_global_grid_size = "(user defined)" ;
            calculate = 0 ;
          } else {
            if( strcmp( argv[i] , "-angle_step" ) == 0 ) {
              i ++ ;
              if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
                printf( "Bad command line\n" ) ;
                exit( EXIT_FAILURE ) ;
              }
              sscanf( argv[i] , "%d" , &angle_step ) ;
              default_angle_step = "(user defined)" ;
            } else {
              if( strcmp( argv[i] , "-surface" ) == 0 ) {
                i ++ ;
                if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
                  printf( "Bad command line\n" ) ;
                  exit( EXIT_FAILURE ) ;
                }
                sscanf( argv[i] , "%f" , &surface ) ;
                default_surface = "(user defined)" ;
              } else {
                if( strcmp( argv[i] , "-internal" ) == 0 ) {
                  i ++ ;
                  if( i == argc ) {
                    printf( "Bad command line\n" ) ;
                    exit( EXIT_FAILURE ) ;
                  }
                  sscanf( argv[i] , "%f" , &internal_value ) ;
                  default_internal_value = "(user defined)" ;
                } else {
                  if( strcmp( argv[i] , "-noelec" ) == 0 ) {
                    electrostatics = 0 ;
                    default_electrostatics = "(user defined)" ;
                  } else {
                    if( strcmp( argv[i] , "-keep" ) == 0 ) {
                      i ++ ;
                      if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
                        printf( "Bad command line\n" ) ;
                        exit( EXIT_FAILURE ) ;
                      }
                      sscanf( argv[i] , "%d" , &keep_per_rotation ) ;
                      default_keep_per_rotation = "(user defined)" ;
                    } else {
                      if( strcmp( argv[i] , "-rescue" ) == 0 ) {
                        rescue = 1 ;
                      } else {
                        if( strcmp( argv[i] , "-calculate_grid" ) == 0 ) {
                          i ++ ;
                          if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
                            printf( "Bad command line\n" ) ;
                            exit( EXIT_FAILURE ) ;
                          }
                          calculate = 1 ;
                          default_global_grid_size = "(user defined calculated)" ;
                          sscanf( argv[i] , "%f" , &reverse_calculated_one_span ) ;
                        } else {
                        	if( strcmp( argv[i] , "-parallel_parts" ) == 0 ) {
                        		i ++ ;
                        		if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
                        		printf( "Bad command line\n" ) ;
                        		exit( EXIT_FAILURE ) ;
                        		}
                        		sscanf( argv[i] , "%d" , &parallel_parts ) ;
                        	} else {
                        		if( strcmp( argv[i] , "-parallel_id" ) == 0 ) {
                        			i ++ ;
                        			if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
                        			printf( "Bad command line\n" ) ;
                        			exit( EXIT_FAILURE ) ;
                        			}
                        			sscanf( argv[i] , "%d" , &parallel_id ) ;
                        		} else {
                            		if( strcmp( argv[i] , "-reduce_translations" ) == 0 ) {
                            			i ++ ;
                            			if( ( i == argc ) || ( strncmp( argv[i] , "-" , 1 ) == 0 ) ) {
                            			printf( "Bad command line\n" ) ;
                            			exit( EXIT_FAILURE ) ;
                            			}
                            			sscanf( argv[i] , "%d" , &reduce_translations ) ;
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
                }
              }
            }
          }
        }
      }
    }

  }

	if(parallel_parts<1)
	{
		printf( "Invalid parallel_parts\n" ) ;
		exit( EXIT_FAILURE ) ;
	}

	if(parallel_id<1 || parallel_id>parallel_parts)
	{
		printf( "Invalid parallel_id, must be between in interval from 1 to parallel_parts\n" ) ;
		exit( EXIT_FAILURE ) ;
	}

/************/

  /* Rescue option */

  if( rescue == 1 ) {

    printf( "RESCUE mode\n" ) ;

    if( ( ftdock_file = fopen( "scratch_parameters.dat" , "r" ) ) == NULL ) {
      printf( "Could not open scratch_parameters.dat for reading.\nDying\n\n" ) ;
      exit( EXIT_FAILURE ) ;
    }

    calculate = 0 ;

    default_global_grid_size = "(read from rescue file)" ;
    default_angle_step = "(read from rescue file)" ;
    default_surface = "(read from rescue file)" ;
    default_internal_value = "(read from rescue file)" ;
    default_electrostatics = "(read from rescue file)" ;

    while( fgets( line_buffer , 99 , ftdock_file ) ) {

      if( strncmp( line_buffer , "Static molecule" , 15 ) == 0 ) sscanf( line_buffer , "Static molecule :: %s" , static_file_name ) ;
      if( strncmp( line_buffer , "Mobile molecule" , 15 ) == 0 ) sscanf( line_buffer , "Mobile molecule :: %s" , mobile_file_name ) ;
      if( strncmp( line_buffer , "Output file name" , 16 ) == 0 ) sscanf( line_buffer , "Output file name :: %s" , output_file_name ) ;
      if( strncmp( line_buffer , "Global grid size" , 16 ) == 0 ) sscanf( line_buffer , "Global grid size :: %d" , &global_grid_size ) ;
      if( strncmp( line_buffer , "Global search angle step" , 24 ) == 0 ) sscanf( line_buffer , "Global search angle step :: %d" , &angle_step ) ;
      if( strncmp( line_buffer , "Global surface thickness" , 24 ) == 0 ) sscanf( line_buffer , "Global surface thickness :: %f" , &surface ) ;
      if( strncmp( line_buffer , "Global internal deterrent value" , 31 ) == 0 ) sscanf( line_buffer , "Global internal deterrent value :: %f" , &internal_value ) ;
      if( strncmp( line_buffer , "Electrostatics                     ::     on" , 44 ) == 0 ) electrostatics = 1 ;    
      if( strncmp( line_buffer , "Electrostatics                     ::    off" , 44 ) == 0 ) electrostatics = 0 ;    
      if( strncmp( line_buffer , "Global keep per rotation" , 25 ) == 0 ) sscanf( line_buffer , "Global keep per rotation :: %d" , &keep_per_rotation ) ;

    }

    fclose( ftdock_file ) ;

    if( ( ftdock_file = fopen( "scratch_scores.dat" , "r" ) ) == NULL ) {
      printf( "Could not open scratch_scores.dat for reading.\nDying\n\n" ) ;
      exit( EXIT_FAILURE ) ;
    }

    fgets( line_buffer , 99 , ftdock_file ) ;

    while( fgets( line_buffer , 99 , ftdock_file ) ) {

      sscanf( line_buffer , "G_DATA %d " , &first_rotation ) ;

    }

    fclose( ftdock_file ) ;

    first_rotation ++ ;

    printf( "Will be starting from rotation %d\n" , first_rotation ) ;

/************/

  } else {

    first_rotation = parallel_id ;

  }

/************/

  /* Do these things first so that bad inputs will be caught soonest */

  /* Read in Structures from pdb files */
  Static_Structure = read_pdb_to_structure( static_file_name ) ;
  Mobile_Structure = read_pdb_to_structure( mobile_file_name ) ;

  if( Mobile_Structure.length > Static_Structure.length ) {
    printf( "WARNING\n" ) ;
    printf( "The mobile molecule has more residues than the static\n" ) ;
    printf( "Are you sure you have the correct molecules?\n" ) ;
    printf( "Continuing anyway\n" ) ;
  }
  
/************/

  /* Get angles */
  Angles = generate_global_angles( angle_step ) ;

  printf( "Total number of rotations is %d\n" , Angles.n ) ;

/************/

  /* Assign charges */

  if( electrostatics == 1 ) {
    printf( "Assigning charges\n" ) ;
    assign_charges( Static_Structure ) ;
    assign_charges( Mobile_Structure ) ;
  }

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

  if( calculate == 1 ) {
    printf( "Using automatic calculation for grid size\n" ) ;
    global_grid_size = (int)( grid_span / reverse_calculated_one_span ) ;
    if( ( global_grid_size % 2 ) != 0 ) { global_grid_size ++ ; }

    /*                                                                                */
    /*  nice_sizes_for_fftw were generated with the following R code:                 */
    /*                                                                                */
    /*  v=c();                                                                        */
    /*  for(a in 1:10)                                                                */
    /*  {                                                                             */
    /*      for(b in 0:6)                                                             */
    /*      {                                                                         */
    /*          for(c in 0:4)                                                         */
    /*          {                                                                     */
    /*              for(d in 0:3)                                                     */
    /*              {                                                                 */
    /*                  for(e in 0:1)                                                 */
    /*                  {                                                             */
    /*                      for(f in 0:1)                                             */
    /*                      {                                                         */
    /*                          if((e+f)<2)                                           */
    /*                          {                                                     */
    /*                              v=c(v, (2^a)*(3^b)*(5^c)*(7^d)*(11^e)*(13^f));    */
    /*                          }                                                     */
    /*                      }                                                         */
    /*                  }                                                             */
    /*              }                                                                 */
    /*          }                                                                     */
    /*      }                                                                         */
    /*  }                                                                             */
    /*  v=union(v, v);                                                                */
    /*  v=sort(v);                                                                    */
    /*  x=c(0, v[which(v>=64 & v<=1024)]);                                            */
    /*                                                                                */
    /*                                                                                */

    int nice_sizes_for_fftw[134]={0, 64, 66, 70, 72, 78, 80, 84, 88, 90, 96, 98, 100, 104, 108,
    		                      110, 112, 120, 126, 128, 130, 132, 140, 144, 150, 154, 156, 160, 162, 168,
    		                      176, 180, 182, 192, 196, 198, 200, 208, 210, 216, 220, 224, 234, 240, 250,
    		                      252, 256, 260, 264, 270, 280, 288, 294, 300, 308, 312, 320, 324, 330, 336,
    		                      350, 352, 360, 364, 378, 384, 390, 392, 396, 400, 416, 420, 432, 440, 448,
    		                      450, 462, 468, 480, 486, 490, 500, 504, 512, 520, 528, 540, 546, 550, 560,
    		                      576, 588, 594, 600, 616, 624, 630, 640, 648, 650, 660, 672, 686, 700, 702,
    		                      704, 720, 728, 750, 756, 768, 770, 780, 784, 792, 800, 810, 832, 840, 864,
    		                      880, 882, 896, 900, 910, 924, 936, 960, 972, 980, 990, 1000, 1008, 1024};
    for(i=0;(i+1)<134;i++)
    {
    	if(global_grid_size>nice_sizes_for_fftw[i] && global_grid_size<nice_sizes_for_fftw[i+1])
    	{
    		global_grid_size=nice_sizes_for_fftw[i+1];
    	}
    }
  }

  one_span = grid_span / (float)global_grid_size ;

  printf( "Span = %.3f angstroms\n" , grid_span ) ;
  printf( "Grid size = %d\n" , global_grid_size ) ;
  printf( "Each Grid cube = %.5f angstroms\n" , one_span ) ;

/************/

  /* Memory Allocation */

  if( ( Scores = ( struct Score * ) malloc ( ( keep_per_rotation + 2 ) * sizeof( struct Score ) ) ) == NULL ) {
    GENERAL_MEMORY_PROBLEM
  }

  if(
    ( ( static_grid = ( fftw_real * ) malloc
     ( global_grid_size * global_grid_size * ( 2 * ( global_grid_size / 2 + 1 ) ) * sizeof( fftw_real ) ) ) == NULL )
    ||
    ( ( mobile_grid = ( fftw_real * ) malloc
     ( global_grid_size * global_grid_size * ( 2 * ( global_grid_size / 2 + 1 ) ) * sizeof( fftw_real ) ) ) == NULL )
    ||
    ( ( convoluted_grid = ( fftw_real * ) malloc
     ( global_grid_size * global_grid_size * ( 2 * ( global_grid_size / 2 + 1 ) ) * sizeof( fftw_real ) ) ) == NULL )
    ) {
    printf( "Not enough memory for surface grids\nUse (sensible) smaller grid size\nDying\n\n" ) ;
    exit( EXIT_FAILURE ) ;
  }

  static_fsg = ( fftw_complex * ) static_grid ;
  mobile_fsg = ( fftw_complex * ) mobile_grid ;
  multiple_fsg = ( fftw_complex * ) convoluted_grid ;

  if( electrostatics == 1 ) {

    if(
      ( ( static_elec_grid = ( fftw_real * ) malloc
       ( global_grid_size * global_grid_size * ( 2 * ( global_grid_size / 2 + 1 ) ) * sizeof( fftw_real ) ) ) == NULL )
      ||
      ( ( mobile_elec_grid = ( fftw_real * ) malloc
       ( global_grid_size * global_grid_size * ( 2 * ( global_grid_size / 2 + 1 ) ) * sizeof( fftw_real ) ) ) == NULL )
      ||
      ( ( convoluted_elec_grid = ( fftw_real * ) malloc
       ( global_grid_size * global_grid_size * ( 2 * ( global_grid_size / 2 + 1 ) ) * sizeof( fftw_real ) ) ) == NULL )
      ) {
      printf( "Not enough memory for electrostatic grids\nSwitch off electrostatics or use (sensible) smaller grid size\nDying\n\n" ) ;
      exit( EXIT_FAILURE ) ;
    } else {
      /* all ok */
      printf( "Electrostatics are on\n" ) ;
    }

    static_elec_fsg = ( fftw_complex * ) static_elec_grid ;
    mobile_elec_fsg = ( fftw_complex * ) mobile_elec_grid ;
    multiple_elec_fsg = ( fftw_complex * ) convoluted_elec_grid ;

  }

/************/

  /* Create FFTW plans */

  printf( "Creating plans\n" ) ;
  p    = rfftw3d_create_plan( global_grid_size , global_grid_size , global_grid_size ,
                               FFTW_REAL_TO_COMPLEX , FFTW_MEASURE | FFTW_IN_PLACE ) ;
  pinv = rfftw3d_create_plan( global_grid_size , global_grid_size , global_grid_size ,
                               FFTW_COMPLEX_TO_REAL , FFTW_MEASURE | FFTW_IN_PLACE ) ;

/************/

  printf( "Setting up Static Structure\n" ) ;

  /* Discretise and surface the Static Structure (need do only once) */
  discretise_structure( Origin_Static_Structure , grid_span , global_grid_size , static_grid ) ;
  printf( "  surfacing grid\n" ) ;
  surface_grid( grid_span , global_grid_size , static_grid , surface , internal_value ) ;

  /* Calculate electic field at all grid nodes (need do only once) */
  if( electrostatics == 1 ) {
    electric_field( Origin_Static_Structure , grid_span , global_grid_size , static_elec_grid ) ;
    electric_field_zero_core( global_grid_size , static_elec_grid , static_grid , internal_value ) ;
  }

  /* Fourier Transform the static grids (need do only once) */
  printf( "  one time forward FFT calculations\n" ) ;
  rfftwnd_one_real_to_complex( p , static_grid , NULL ) ;
  if( electrostatics == 1 ) {
    rfftwnd_one_real_to_complex( p , static_elec_grid , NULL ) ;
  }

  printf( "  done\n" ) ;

/************/

  /* Store paramaters in case of rescue */

  if( ( ftdock_file = fopen( "scratch_parameters.dat" , "w" ) ) == NULL ) {
    printf( "Could not open scratch_parameters.dat for writing.\nDying\n\n" ) ;
    exit( EXIT_FAILURE ) ;
  }

  fprintf( ftdock_file, "\nGlobal Scan\n" ) ;

  fprintf( ftdock_file, "\nCommand line controllable values\n" ) ;
  fprintf( ftdock_file, "Static molecule                    :: %s\n" , static_file_name ) ;
  fprintf( ftdock_file, "Mobile molecule                    :: %s\n" , mobile_file_name ) ;
  fprintf( ftdock_file, "Output file name                   :: %s\n" , output_file_name ) ;
  fprintf( ftdock_file, "\n" ) ;
  fprintf( ftdock_file, "Global grid size                   :: %6d      %s\n" , global_grid_size , default_global_grid_size ) ;
  fprintf( ftdock_file, "Global search angle step           :: %6d      %s\n" , angle_step , default_angle_step ) ;
  fprintf( ftdock_file, "Global surface thickness           :: %9.2f   %s\n" , surface , default_surface ) ;
  fprintf( ftdock_file, "Global internal deterrent value    :: %9.2f   %s\n" , internal_value , default_internal_value ) ;
  if( electrostatics == 1 ) {
    fprintf( ftdock_file, "Electrostatics                     ::     on      %s\n" , default_electrostatics ) ;
  } else {
    fprintf( ftdock_file, "Electrostatics                     ::    off      %s\n" , default_electrostatics ) ;
  }
  fprintf( ftdock_file, "Global keep per rotation           :: %6d      %s\n" , keep_per_rotation , default_keep_per_rotation ) ;

  fprintf( ftdock_file, "\nCalculated values\n" ) ;
  fprintf( ftdock_file, "Global rotations                   :: %6d\n" , Angles.n ) ;
  fprintf( ftdock_file, "Global total span (angstroms)      :: %10.3f\n" , grid_span ) ;
  fprintf( ftdock_file, "Global grid cell span (angstroms)  :: %10.3f\n" , one_span ) ;

  fclose( ftdock_file ) ;

/************/

  /* Main program loop */

  max_es_value = 0 ;

  printf( "Starting main loop through the rotations\n" ) ;

  for( rotation = first_rotation ; rotation <= Angles.n ; rotation = rotation + parallel_parts ) {

    printf( "." ) ; 

    if( ( ((rotation-first_rotation)/parallel_parts+1) % 50 ) == 0 ) printf( "\nRotation number %5d\n" , rotation ) ;

    /* Rotate Mobile Structure */
    Rotated_at_Origin_Mobile_Structure =
     rotate_structure( Origin_Mobile_Structure , (int)Angles.z_twist[rotation] , (int)Angles.theta[rotation] , (int)Angles.phi[rotation] ) ;

    /* Discretise the rotated Mobile Structure */
    discretise_structure( Rotated_at_Origin_Mobile_Structure , grid_span , global_grid_size , mobile_grid ) ;

    /* Electic point charge approximation onto grid calculations ( quicker than filed calculations by a long way! ) */
    if( electrostatics == 1 ) {
      electric_point_charge( Rotated_at_Origin_Mobile_Structure , grid_span , global_grid_size , mobile_elec_grid ) ;
    }

    /* Forward Fourier Transforms */
    rfftwnd_one_real_to_complex( p , mobile_grid , NULL ) ;
    if( electrostatics == 1 ) {
      rfftwnd_one_real_to_complex( p , mobile_elec_grid , NULL ) ;
    }

/************/

    /* Do convolution of the two sets of grids
       convolution is equivalent to multiplication of the complex conjugate of one
       fourier grid with other (raw) one
       hence the sign changes from a normal complex number multiplication
    */

    for( fx = 0 ; fx < global_grid_size ; fx ++ ) {
      for( fy = 0 ; fy < global_grid_size ; fy ++ ) {
        for( fz = 0 ; fz < global_grid_size/2 + 1 ; fz ++ ) {

          fxyz = fz + ( global_grid_size/2 + 1 ) * ( fy + global_grid_size * fx ) ;

          multiple_fsg[fxyz].re =
           static_fsg[fxyz].re * mobile_fsg[fxyz].re + static_fsg[fxyz].im * mobile_fsg[fxyz].im ;
          multiple_fsg[fxyz].im =
           static_fsg[fxyz].im * mobile_fsg[fxyz].re - static_fsg[fxyz].re * mobile_fsg[fxyz].im ;
           
          if( electrostatics == 1 ) {
            multiple_elec_fsg[fxyz].re =
             static_elec_fsg[fxyz].re * mobile_elec_fsg[fxyz].re + static_elec_fsg[fxyz].im * mobile_elec_fsg[fxyz].im ;
            multiple_elec_fsg[fxyz].im =
             static_elec_fsg[fxyz].im * mobile_elec_fsg[fxyz].re - static_elec_fsg[fxyz].re * mobile_elec_fsg[fxyz].im ;
          }

        }
      }
    }

    /* Reverse Fourier Transform */
    rfftwnd_one_complex_to_real( pinv , multiple_fsg , NULL ) ;
    if( electrostatics == 1 ) {
      rfftwnd_one_complex_to_real( pinv , multiple_elec_fsg , NULL ) ;
    }

/************/

    /* Get best scores */

    for( i = 0 ; i < keep_per_rotation ; i ++ ) {

      Scores[i].score = 0 ;
      Scores[i].rpscore = 0.0 ;
      Scores[i].coord[1] = 0 ;
      Scores[i].coord[2] = 0 ;
      Scores[i].coord[3] = 0 ;

    }

    for( x = 0 ; x < global_grid_size ; x ++ ) {
      fx = x ;
      if( fx > ( global_grid_size / 2 ) ) fx -= global_grid_size ;

      for( y = 0 ; y < global_grid_size ; y ++ ) {
        fy = y ;
        if( fy > ( global_grid_size / 2 ) ) fy -= global_grid_size ;

        for( z = 0 ; z < global_grid_size ; z ++ ) {
          fz = z ;
          if( fz > ( global_grid_size / 2 ) ) fz -= global_grid_size ;

          xyz = z + ( 2 * ( global_grid_size / 2 + 1 ) ) * ( y + global_grid_size * x ) ;

          if( ( electrostatics == 0 ) || ( convoluted_elec_grid[xyz] < 0 ) ) {

            /* Scale factor from FFTs */
            if( (int)convoluted_grid[xyz] != 0 ) {
              convoluted_grid[xyz] /= ( global_grid_size * global_grid_size * global_grid_size ) ;
            }

            if( (int)convoluted_grid[xyz] > Scores[keep_per_rotation-1].score ) {

              i = keep_per_rotation - 2 ;

              while( ( (int)convoluted_grid[xyz] > Scores[i].score ) && ( i >= 0 ) ) {
                Scores[i+1].score    = Scores[i].score ;
                Scores[i+1].rpscore  = Scores[i].rpscore ;
                Scores[i+1].coord[1] = Scores[i].coord[1] ;
                Scores[i+1].coord[2] = Scores[i].coord[2] ;
                Scores[i+1].coord[3] = Scores[i].coord[3] ;
                i -- ;
              }

              Scores[i+1].score    = (int)convoluted_grid[xyz] ;
              if( ( electrostatics != 0 ) && ( convoluted_elec_grid[xyz] < 0.1 ) ) {
                Scores[i+1].rpscore  = (float)convoluted_elec_grid[xyz] ;
              } else {
                Scores[i+1].rpscore  = (float)0 ;
              }
              Scores[i+1].coord[1] = fx ;
              Scores[i+1].coord[2] = fy ;
              Scores[i+1].coord[3] = fz ;

            }

          }

        }
      }
    }

    if( rotation == 1 ) {
      if( ( ftdock_file = fopen( "scratch_scores.dat" , "w" ) ) == NULL ) {
        printf( "Could not open scratch_scores.dat for writing.\nDying\n\n" ) ;
        exit( EXIT_FAILURE ) ;
      }
    } else {
      if( ( ftdock_file = fopen( "scratch_scores.dat" , "a" ) ) == NULL ) {
        printf( "Could not open scratch_scores.dat for writing.\nDying\n\n" ) ;
        exit( EXIT_FAILURE ) ;
      }
    }

    for( i = 0 ; i < keep_per_rotation ; i ++ )
    {
		case_found=0;
		if(reduce_translations>0)
		{
			for(j=0;j<i && case_found==0;j++)
			{
				if(((Scores[i].coord[1]-Scores[j].coord[1])*(Scores[i].coord[1]-Scores[j].coord[1])+
				    (Scores[i].coord[2]-Scores[j].coord[2])*(Scores[i].coord[2]-Scores[j].coord[2])+
				    (Scores[i].coord[3]-Scores[j].coord[3])*(Scores[i].coord[3]-Scores[j].coord[3]))<reduce_translations)
				{
					case_found=1;
				}
			}
		}

		if(case_found==0)
		{
			max_es_value = min( max_es_value , Scores[i].rpscore ) ;
			fprintf( ftdock_file, "G_DATA %6d   %6d    %7d       %.0f      %4d %4d %4d      %4d%4d%4d\n" ,
					rotation , 0 , Scores[i].score , (double)Scores[i].rpscore , Scores[i].coord[1] , Scores[i].coord[2] , Scores[i].coord[3 ] ,
					 Angles.z_twist[rotation] , Angles.theta[rotation]  , Angles.phi[rotation] ) ;
		}
    }

    fclose( ftdock_file ) ;

    /* Free some memory */
    for( i = 1 ; i <= Rotated_at_Origin_Mobile_Structure.length ; i ++ ) {
      free( Rotated_at_Origin_Mobile_Structure.Residue[i].Atom ) ;
    }
    free( Rotated_at_Origin_Mobile_Structure.Residue ) ;

  }

  /* Finished main loop */

/************/

  /* Free the memory */

  rfftwnd_destroy_plan( p ) ;
  rfftwnd_destroy_plan( pinv ) ;

  free( static_grid ) ;
  free( mobile_grid ) ;
  free( convoluted_grid ) ;

  if( electrostatics == 1 ) {
    free( static_elec_grid ) ;
    free( mobile_elec_grid ) ;
    free( convoluted_elec_grid ) ;
  }

  for( i = 1 ; i <= Origin_Static_Structure.length ; i ++ ) {
    free( Origin_Static_Structure.Residue[i].Atom ) ;
  }
  free( Origin_Static_Structure.Residue ) ;

  for( i = 1 ; i <= Origin_Mobile_Structure.length ; i ++ ) {
    free( Origin_Mobile_Structure.Residue[i].Atom ) ;
  }
  free( Origin_Mobile_Structure.Residue ) ;

/************/

  /* Read in all the scores */

  printf( "\nReloading all the scores\n" ) ;

  if( ( ftdock_file = fopen( "scratch_scores.dat" , "r" ) ) == NULL ) {
    printf( "Could not open scratch_scores.dat for reading.\nDying\n\n" ) ;
    exit( EXIT_FAILURE ) ;
  }

  if( ( Scores = ( struct Score * ) realloc ( Scores , ( 1 + keep_per_rotation ) * Angles.n * sizeof( struct Score ) ) ) == NULL ) {
    printf( "Not enough memory left for storing scores\nProbably keeping too many per rotation\nDying\n\n" ) ;
    exit( EXIT_FAILURE ) ;
  }

  kept_scores = 0 ;

  while( fgets( line_buffer , 99 , ftdock_file ) ) {

    sscanf( line_buffer , "G_DATA %d %d %d %f  %d %d %d  %d %d %d" , &id , &id2 , &SCscore , &RPscore ,
                                                                     &x , &y , &z , &z_twist , &theta , &phi ) ;

    Scores[kept_scores].score    = SCscore ;
    Scores[kept_scores].rpscore  = RPscore ;
    Scores[kept_scores].coord[1] = x ;
    Scores[kept_scores].coord[2] = y ;
    Scores[kept_scores].coord[3] = z ;
    Scores[kept_scores].angle[1] = z_twist ;
    Scores[kept_scores].angle[2] = theta ;
    Scores[kept_scores].angle[3] = phi ;

    kept_scores ++ ;

  }

  fclose( ftdock_file ) ;

  kept_scores -- ;

  qsort_scores( Scores , 0 , kept_scores ) ;

/************/

  /* Writing data file */

  if( ( ftdock_file = fopen( output_file_name , "w" ) ) == NULL ) {
    printf( "Could not open %s for writing.\nDying\n\n" , output_file_name ) ;
    exit( EXIT_FAILURE ) ;
  }

  fprintf( ftdock_file, "FTDOCK data file\n" ) ;

  fprintf( ftdock_file, "\nGlobal Scan\n" ) ;

  fprintf( ftdock_file, "\nCommand line controllable values\n" ) ;
  fprintf( ftdock_file, "Static molecule                    :: %s\n" , static_file_name ) ;
  fprintf( ftdock_file, "Mobile molecule                    :: %s\n" , mobile_file_name ) ;
  fprintf( ftdock_file, "\n" ) ;
  fprintf( ftdock_file, "Global grid size                   :: %6d      %s\n" , global_grid_size , default_global_grid_size ) ;
  fprintf( ftdock_file, "Global search angle step           :: %6d      %s\n" , angle_step , default_angle_step ) ;
  fprintf( ftdock_file, "Global surface thickness           :: %9.2f   %s\n" , surface , default_surface ) ;
  fprintf( ftdock_file, "Global internal deterrent value    :: %9.2f   %s\n" , internal_value , default_internal_value ) ;
  if( electrostatics == 1 ) {
    fprintf( ftdock_file, "Electrostatics                     ::     on      %s\n" , default_electrostatics ) ;
  } else {
    fprintf( ftdock_file, "Electrostatics                     ::    off      %s\n" , default_electrostatics ) ;
  }
  fprintf( ftdock_file, "Global keep per rotation           :: %6d      %s\n" , keep_per_rotation , default_keep_per_rotation ) ;

  fprintf( ftdock_file, "\nCalculated values\n" ) ;
  fprintf( ftdock_file, "Global rotations                   :: %6d\n" , Angles.n ) ;
  fprintf( ftdock_file, "Global total span (angstroms)      :: %10.3f\n" , grid_span ) ;
  fprintf( ftdock_file, "Global grid cell span (angstroms)  :: %10.3f\n" , one_span ) ;

  fprintf( ftdock_file, "\nData\n" ) ;
  fprintf( ftdock_file , "Type       ID    prvID    SCscore        ESratio         Coordinates            Angles\n\n" ) ;

  if( electrostatics == 1 ) {

    for( i = 0 ; i <= min( kept_scores , ( NUMBER_TO_KEEP - 1 ) ) ; i ++ ) {

      fprintf( ftdock_file, "G_DATA %6d   %6d    %7d       %8.3f      %4d %4d %4d      %4d%4d%4d\n" ,
               i + 1 , 0 , Scores[i].score , 100 * ( Scores[i].rpscore / max_es_value ) ,
               Scores[i].coord[1] , Scores[i].coord[2] , Scores[i].coord[3] ,
               Scores[i].angle[1] , Scores[i].angle[2] , Scores[i].angle[3] ) ;

    }

  } else {

    for( i = 0 ; i <= min( kept_scores , ( NUMBER_TO_KEEP - 1 ) ) ; i ++ ) {

      fprintf( ftdock_file, "G_DATA %6d   %6d    %7d       %8.3f      %4d %4d %4d      %4d%4d%4d\n" ,
               i + 1 , 0 , Scores[i].score , 0.0 ,
               Scores[i].coord[1] , Scores[i].coord[2] , Scores[i].coord[3] ,
               Scores[i].angle[1] , Scores[i].angle[2] , Scores[i].angle[3] ) ;

    }

  }

  fclose( ftdock_file ) ;
    
/************/

  printf( "\n\nFinished\n\n" ) ;

  return( 0 ) ;

} /* end main */
