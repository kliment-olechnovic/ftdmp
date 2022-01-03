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

struct Structure read_pdb_to_structure( char *pdb_file_name ) {

/************/

  /* Variables */

  /* Counters */
  int	n_residues ;	/* number of residues */
  int	res_size ;	/* number of atoms in single residue */

  /* File stuff */
  FILE	*pdb_file ;
  char	line_buffer[100] ;

  /* What the data is going into */
  struct Structure		This_Structure ;

  /* Variables from the PDB file */
  int	serial ;
  char		atom_name[5] ;
  char		res_name[4] ;
  char		chainID[2] ;
  char		res_seq_plus_iCode[6] ;
  float		coord_x , coord_y , coord_z ;
  float		occupancy, temp_factor ;
  char		olc[2] ;
  int		nc ;

  /* Comparison values */
  char	present_res_seq_plus_iCode[6] ;

/************/

  setvbuf( stdout , (char *)NULL , _IONBF , 0 ) ;

  /* File handling */

  /* Open file */
  printf( "  reading parsed pdb file: %s\n", pdb_file_name ) ;
  if( ( pdb_file = fopen( pdb_file_name, "r" ) ) == NULL ) {
    printf( "This file does not exist here, or is unreadable.\nDying\n\n" ) ;
    exit( EXIT_FAILURE ) ;
  }

/************/

  /* Initialisations */

  /* Counters */
  n_residues = 0 ;
  res_size = 0 ;

  /* Comparison values */
  strcpy( present_res_seq_plus_iCode , ">" ) ;

  /* Memory allocation */
  if( ( This_Structure.Residue = ( struct Amino_Acid * ) malloc ( sizeof_Amino_Acid ) ) == NULL ) {
    GENERAL_MEMORY_PROBLEM
  }

/************/

  /* Read PDB file */

  /* The Atoms */

  while( fgets( line_buffer, 85, pdb_file ) ) {

    if( strncmp( line_buffer, "ATOM", 4 ) == 0 ) {

      /* Have an ATOM */

      /* Get Values */

      /* the following may seem silly, but sscanf convention means that two
         float fields with no white space between them, where the first is
         less than the maximum field width, mucks up everything.
      */

      sscanf( line_buffer +  6 , "%5d" , &serial ) ;
      sscanf( line_buffer + 30 , "%8f" , &coord_x ) ;
      sscanf( line_buffer + 38 , "%8f" , &coord_y ) ;
      sscanf( line_buffer + 46 , "%8f" , &coord_z ) ;
      sscanf( line_buffer + 54 , "%6f" , &occupancy ) ;
      sscanf( line_buffer + 60 , "%6f" , &temp_factor ) ;
      sscanf( line_buffer + 82 , "%2d" , &nc ) ;

      strncpy( atom_name,		line_buffer+12,	4 ) ;
      strncpy( res_name,		line_buffer+17,	3 ) ;
      strncpy( chainID,			line_buffer+21,	1 ) ;
      strncpy( res_seq_plus_iCode,	line_buffer+22,	5 ) ;
      strncpy( olc,			line_buffer+80,	1 ) ;

      strncpy( atom_name + 4,		"\0", 1 ) ;
      strncpy( res_name + 3,		"\0", 1 ) ;
      strncpy( chainID + 1,		"\0", 1 ) ;
      strncpy( res_seq_plus_iCode + 5,	"\0", 1 ) ;
      strncpy( olc + 1,			"\0", 1 ) ;

/************/

      /* New Residue */

      if( strcmp( res_seq_plus_iCode , present_res_seq_plus_iCode ) != 0 ) {

        /* have next residue */

        /* Store old info */
        This_Structure.Residue[n_residues].size = res_size ;

        /* Increment, Reset numbers */
        n_residues ++ ;
        res_size = 0 ;

        /* Memory management */
        if( ( This_Structure.Residue = (struct Amino_Acid * ) realloc ( This_Structure.Residue, ( n_residues + 1 ) * sizeof_Amino_Acid ) ) == NULL ) {
          GENERAL_MEMORY_PROBLEM
        }
        if( ( This_Structure.Residue[n_residues].Atom = ( struct Atom * ) malloc ( sizeof_Atom ) ) == NULL ) {
          GENERAL_MEMORY_PROBLEM
        }

        /* Store new info */
        strcpy( This_Structure.Residue[n_residues].res_seq_plus_iCode , res_seq_plus_iCode );
        strcpy( This_Structure.Residue[n_residues].res_name ,           res_name ) ;
        strcpy( This_Structure.Residue[n_residues].chainID ,            chainID ) ;
        strcpy( This_Structure.Residue[n_residues].olc,                 olc ) ;
        This_Structure.Residue[n_residues].nc = nc ;

      }

      strcpy( present_res_seq_plus_iCode , res_seq_plus_iCode ) ;

/************/

      /* Put Atoms into Structure */

      res_size ++ ;

      if( ( This_Structure.Residue[n_residues].Atom = ( struct Atom * ) realloc ( This_Structure.Residue[n_residues].Atom, ( res_size + 1 ) * sizeof_Atom ) ) == NULL ) {
        GENERAL_MEMORY_PROBLEM
      }

      This_Structure.Residue[n_residues].Atom[res_size].serial = serial ;
      strcpy( This_Structure.Residue[n_residues].Atom[res_size].atom_name, atom_name ) ;
      This_Structure.Residue[n_residues].Atom[res_size].coord[1] = coord_x ;
      This_Structure.Residue[n_residues].Atom[res_size].coord[2] = coord_y ;
      This_Structure.Residue[n_residues].Atom[res_size].coord[3] = coord_z ;
      This_Structure.Residue[n_residues].Atom[res_size].occupancy = occupancy ;
      This_Structure.Residue[n_residues].Atom[res_size].temp_factor = temp_factor ;

/************/

    }

  } /* got to end of pdb file */

/************/

  /* Clean up */

  This_Structure.Residue[n_residues].size = res_size ;
  This_Structure.length = n_residues ;
  strcpy( This_Structure.ident , pdb_file_name  );

  /* Finish off */

  fclose( pdb_file ) ;

  return This_Structure ;

}



/************************/



void write_structure_to_pdb( struct Structure This_Structure , char *pdb_file_name ) {

/************/

  /* Variables */

  /* Counters */
  int	residue , atom ;

  /* File stuff */
  FILE		*pdb_file ;

/************/

  /* File handling */

  /* Open file */
  printf( "Writing file: %s\n", pdb_file_name ) ;
  if( ( pdb_file = fopen( pdb_file_name, "w" ) ) == NULL ) {
    printf( "This file could not be opened.\nDying\n\n" ) ;
    exit(  EXIT_FAILURE ) ;
  }

/************/

  /* Write PDB file */

  for( residue = 1 ; residue <= This_Structure.length ; residue ++ ) {

    for( atom = 1 ; atom <= This_Structure.Residue[residue].size ; atom ++ ) {

      fprintf( pdb_file, "ATOM  %5d %4s %3s %1s%5s   %8.3f%8.3f%8.3f%6.2f%6.2f              %1s %2d\n", This_Structure.Residue[residue].Atom[atom].serial, This_Structure.Residue[residue].Atom[atom].atom_name, This_Structure.Residue[residue].res_name, This_Structure.Residue[residue].chainID, This_Structure.Residue[residue].res_seq_plus_iCode, This_Structure.Residue[residue].Atom[atom].coord[1], This_Structure.Residue[residue].Atom[atom].coord[2], This_Structure.Residue[residue].Atom[atom].coord[3], This_Structure.Residue[residue].Atom[atom].occupancy, This_Structure.Residue[residue].Atom[atom].temp_factor, This_Structure.Residue[residue].olc, This_Structure.Residue[residue].nc ) ;

    }

  }

/************/

  /* Finish off */

  fclose( pdb_file ) ;

}



/************************/



struct Structure duplicate_structure( struct Structure This_Structure ) {

/************/

  /* Variables */
  struct Structure	New_Structure ;

  /* Counters */
  int		residue , atom ;

/************/

  if( ( New_Structure.Residue = ( struct Amino_Acid * ) malloc ( ( This_Structure.length + 1 ) * sizeof_Amino_Acid ) ) == NULL ) {
    GENERAL_MEMORY_PROBLEM
  }

  strcpy( New_Structure.ident , This_Structure.ident ) ;
  New_Structure.length = This_Structure.length ;

  for( residue = 1 ; residue <= This_Structure.length ; residue ++ ) {

    New_Structure.Residue[residue] = This_Structure.Residue[residue] ;

    if( ( New_Structure.Residue[residue].Atom = ( struct Atom * ) malloc ( ( This_Structure.Residue[residue].size + 1 ) * sizeof_Atom ) ) == NULL ) {
      GENERAL_MEMORY_PROBLEM
    }

    for( atom = 1 ; atom <= This_Structure.Residue[residue].size ; atom ++ ) {

      New_Structure.Residue[residue].Atom[atom] = This_Structure.Residue[residue].Atom[atom] ;

    }

  }

  return New_Structure ;

/************/

}



/************************/



struct Structure translate_structure( struct Structure This_Structure , float x_shift , float y_shift , float z_shift ) {

/************/

  /* Variables */
  struct Structure	New_Structure ;

  /* Counters */
  int		residue , atom ;

/************/

  New_Structure = duplicate_structure( This_Structure ) ;

/************/

  for( residue = 1 ; residue <= New_Structure.length ; residue ++ ) {

    for( atom = 1 ; atom <= New_Structure.Residue[residue].size ; atom ++ ) {

      New_Structure.Residue[residue].Atom[atom].coord[1] += x_shift ;
      New_Structure.Residue[residue].Atom[atom].coord[2] += y_shift ;
      New_Structure.Residue[residue].Atom[atom].coord[3] += z_shift ;

    }

  }

  return New_Structure ;

/************/

}



/************************/



struct Structure translate_structure_onto_origin( struct Structure This_Structure ) {

/************/

  /* Variables */
  struct Structure	New_Structure ;

  float			average_x , average_y , average_z ;

  /* Counters */
  int		residue , atom , total_atoms ;

/************/

  New_Structure = duplicate_structure( This_Structure ) ;

/************/

  /* Find current centre */

  total_atoms = 0 ;

  average_x = 0 ;
  average_y = 0 ;
  average_z = 0 ;

  for( residue = 1 ; residue <= New_Structure.length ; residue ++ ) {

    for( atom = 1 ; atom <= New_Structure.Residue[residue].size ; atom ++ ) {

      total_atoms ++ ;

      average_x += New_Structure.Residue[residue].Atom[atom].coord[1] ;
      average_y += New_Structure.Residue[residue].Atom[atom].coord[2] ;
      average_z += New_Structure.Residue[residue].Atom[atom].coord[3] ;

    }

  }

  average_x = average_x / (float)total_atoms ;
  average_y = average_y / (float)total_atoms ;
  average_z = average_z / (float)total_atoms ;

/************/

  /* Translate */

  for( residue = 1 ; residue <= New_Structure.length ; residue ++ ) {

    for( atom = 1 ; atom <= New_Structure.Residue[residue].size ; atom ++ ) {

      New_Structure.Residue[residue].Atom[atom].coord[1] -= average_x ;
      New_Structure.Residue[residue].Atom[atom].coord[2] -= average_y ;
      New_Structure.Residue[residue].Atom[atom].coord[3] -= average_z ;

    }

  }

  return New_Structure ;

/************/

}



/************************/



struct Structure rotate_structure( struct Structure This_Structure , int z_twist , int theta , int phi ) {

/************/

  /* Variables */
  struct Structure	New_Structure ;

  float			post_z_twist_x , post_z_twist_y , post_z_twist_z ;
  float			post_theta_x , post_theta_y , post_theta_z ;

  /* Counters */
  int		residue , atom ;

/************/

  New_Structure = duplicate_structure( This_Structure ) ;

/************/

  for( residue = 1 ; residue <= New_Structure.length ; residue ++ ) {

    for( atom = 1 ; atom <= New_Structure.Residue[residue].size ; atom ++ ) {

      /* Perform Z axis twist */
      post_z_twist_x = New_Structure.Residue[residue].Atom[atom].coord[1] * cos( 0.017453293 * z_twist ) - New_Structure.Residue[residue].Atom[atom].coord[2] * sin( 0.017453293 * z_twist ) ;
      post_z_twist_y = New_Structure.Residue[residue].Atom[atom].coord[1] * sin( 0.017453293 * z_twist ) + New_Structure.Residue[residue].Atom[atom].coord[2] * cos( 0.017453293 * z_twist ) ;
      post_z_twist_z = New_Structure.Residue[residue].Atom[atom].coord[3] ;

      /* Perform theta twist along plane of x-z */
      post_theta_x = post_z_twist_z * sin( 0.017453293 * theta ) + post_z_twist_x * cos( 0.017453293 * theta ) ; 
      post_theta_y = post_z_twist_y ;
      post_theta_z = post_z_twist_z * cos( 0.017453293 * theta ) - post_z_twist_x * sin( 0.017453293 * theta ) ; 

      /* Perform phi twist around z axis */
      New_Structure.Residue[residue].Atom[atom].coord[1] = post_theta_x * cos( 0.017453293 * phi ) - post_theta_y * sin( 0.017453293 * phi ) ;
      New_Structure.Residue[residue].Atom[atom].coord[2] = post_theta_x * sin( 0.017453293 * phi ) + post_theta_y * cos( 0.017453293 * phi ) ;
      New_Structure.Residue[residue].Atom[atom].coord[3] = post_theta_z ;

    }

  }

  return New_Structure ;

/************/

}



/************************/



struct Structure merge_structures( struct Structure Structure_One , struct Structure Structure_Two ) {

/************/

  /* Variables */
  struct Structure	New_Structure ;

  /* Counters */
  int		residue , atom , new_residue ;

/************/

  if( ( New_Structure.Residue = ( struct Amino_Acid * ) malloc ( ( Structure_One.length + Structure_Two.length + 1 ) * sizeof_Amino_Acid ) ) == NULL ) {
    GENERAL_MEMORY_PROBLEM
  }

  strcpy( New_Structure.ident , "Complex" ) ;
  New_Structure.length = Structure_One.length + Structure_Two.length ;

  for( residue = 1 ; residue <= Structure_One.length ; residue ++ ) {

    if( ( New_Structure.Residue[residue].Atom = ( struct Atom * ) malloc ( ( Structure_One.Residue[residue].size + 1 ) * sizeof_Atom ) ) == NULL ) {
      GENERAL_MEMORY_PROBLEM
    }
    strcpy( New_Structure.Residue[residue].res_name           , Structure_One.Residue[residue].res_name ) ;
    strcpy( New_Structure.Residue[residue].chainID            , Structure_One.Residue[residue].chainID ) ;
    strcpy( New_Structure.Residue[residue].res_seq_plus_iCode , Structure_One.Residue[residue].res_seq_plus_iCode ) ;
    strcpy( New_Structure.Residue[residue].olc                , Structure_One.Residue[residue].olc ) ;
    New_Structure.Residue[residue].nc                         = Structure_One.Residue[residue].nc   ;
    New_Structure.Residue[residue].size                       = Structure_One.Residue[residue].size ;

    if( ( New_Structure.Residue[residue].Atom = ( struct Atom * ) malloc ( ( Structure_One.Residue[residue].size + 1 ) * sizeof_Atom ) ) == NULL ) {
      GENERAL_MEMORY_PROBLEM
    }

    for( atom = 1 ; atom <= Structure_One.Residue[residue].size ; atom ++ ) {

      New_Structure.Residue[residue].Atom[atom] = Structure_One.Residue[residue].Atom[atom] ;

    }

  }

  for( residue = 1 ; residue <= Structure_Two.length ; residue ++ ) {

    new_residue = residue + Structure_One.length ;

    strcpy( New_Structure.Residue[new_residue].chainID            , Structure_Two.Residue[residue].chainID ) ;
    strcpy( New_Structure.Residue[new_residue].res_seq_plus_iCode , Structure_Two.Residue[residue].res_seq_plus_iCode ) ;
    strcpy( New_Structure.Residue[new_residue].olc                , Structure_Two.Residue[residue].olc ) ;
    New_Structure.Residue[new_residue].nc                         = Structure_Two.Residue[residue].nc   ;
    New_Structure.Residue[new_residue].size                       = Structure_Two.Residue[residue].size ;
    strcpy( New_Structure.Residue[new_residue].res_name           , Structure_Two.Residue[residue].res_name ) ;

    if( ( New_Structure.Residue[new_residue].Atom = ( struct Atom * ) malloc ( ( Structure_Two.Residue[residue].size + 1 ) * sizeof_Atom ) ) == NULL ) {
      GENERAL_MEMORY_PROBLEM
    }
    for( atom = 1 ; atom <= Structure_Two.Residue[residue].size ; atom ++ ) {

      New_Structure.Residue[new_residue].Atom[atom] = Structure_Two.Residue[residue].Atom[atom] ;

    }

  }

  return New_Structure ;

/************/

}



/************************/



float radius_of_structure( struct Structure This_Structure ) {

/************/

  /* Variables */
  float		present , largest ;

  /* Counters */
  int	residue , atom ;

/************/

  largest = 0 ;

  for( residue = 1 ; residue <= This_Structure.length ; residue ++ ) {

    for( atom = 1 ; atom <= This_Structure.Residue[residue].size ; atom ++ ) {

      present = This_Structure.Residue[residue].Atom[atom].coord[1] * This_Structure.Residue[residue].Atom[atom].coord[1] + This_Structure.Residue[residue].Atom[atom].coord[2] * This_Structure.Residue[residue].Atom[atom].coord[2] + This_Structure.Residue[residue].Atom[atom].coord[3] * This_Structure.Residue[residue].Atom[atom].coord[3] ;

      if( present > largest ) largest = present ;

    }

  }

  return sqrt( largest ) ;

/************/

}



/************************/



float total_span_of_structures( struct Structure Structure_1 , struct Structure Structure_2 ) {

  return  1 + ( ( radius_of_structure( Structure_1 ) + radius_of_structure( Structure_2 ) ) * 2 ) ;

}
