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

void discretise_structure( struct Structure This_Structure , float grid_span , int grid_size , fftw_real *grid ) {

/************/

  /* Counters */

  int	residue , atom ;

  /* Co-ordinates */

  int	x , y , z ;
  int	steps , x_step , y_step , z_step ;

  float		x_centre , y_centre , z_centre ;

  /* Variables */

  float         distance , one_span ;

/************/

  one_span = grid_span / (float)grid_size ;

  distance = 1.8 ;

/************/

  for( x = 0 ; x < grid_size ; x ++ ) {
    for( y = 0 ; y < grid_size ; y ++ ) {
      for( z = 0 ; z < grid_size ; z ++ ) {

        grid[gaddress(x,y,z,grid_size)] = (fftw_real)0 ;

      }
    }
  }

/************/

  steps = (int)( ( distance / one_span ) + 1.5 ) ;

  for( residue = 1 ; residue <= This_Structure.length ; residue ++ ) {
    for( atom = 1 ; atom <= This_Structure.Residue[residue].size ; atom ++ ) {

      x = gord( This_Structure.Residue[residue].Atom[atom].coord[1] , grid_span , grid_size ) ;
      y = gord( This_Structure.Residue[residue].Atom[atom].coord[2] , grid_span , grid_size ) ;
      z = gord( This_Structure.Residue[residue].Atom[atom].coord[3] , grid_span , grid_size ) ;

      for( x_step = max( ( x - steps ) , 0 ) ; x_step <= min( ( x + steps ) , ( grid_size - 1 ) ) ; x_step ++ ) {

        x_centre  = gcentre( x_step , grid_span , grid_size ) ;

        for( y_step = max( ( y - steps ) , 0 ) ; y_step <= min( ( y + steps ) , ( grid_size - 1 ) ) ; y_step ++ ) {

          y_centre  = gcentre( y_step , grid_span , grid_size ) ;

          for( z_step = max( ( z - steps ) , 0 ) ; z_step <= min( ( z + steps ) , ( grid_size - 1 ) ) ; z_step ++ ) {

            z_centre  = gcentre( z_step , grid_span , grid_size ) ;

            if( pythagoras( This_Structure.Residue[residue].Atom[atom].coord[1] , This_Structure.Residue[residue].Atom[atom].coord[2] , This_Structure.Residue[residue].Atom[atom].coord[3] , x_centre , y_centre , z_centre ) < distance ) grid[gaddress(x_step,y_step,z_step,grid_size)] = (fftw_real)1 ;

          }
        }
      }

    }
  }

/************/

  return ;

}



/************************/



void surface_grid( float grid_span , int grid_size , fftw_real *grid , float surface , float internal_value ) {


/************/

  /* Counters */

  int	x , y , z ;
  int	steps , x_step , y_step , z_step ;

  /* Variables */

  float		one_span ;

  int	at_surface ;

/************/

  one_span = grid_span / (float)grid_size ;

/************/

  /* Surface grid atoms */

  steps = (int)( ( surface / one_span ) + 1.5 ) ;

  for( x = 0 ; x < grid_size ; x ++ ) {
    for( y = 0 ; y < grid_size ; y ++ ) {
      for( z = 0 ; z < grid_size ; z ++ ) {

        if( (int)grid[gaddress(x,y,z,grid_size)] == 1 ) {

          at_surface = 0 ;

          for( x_step = max( x - steps , 0 ) ; x_step <= min( x + steps , grid_size - 1 ) ; x_step ++ ) {
            for( y_step = max( y - steps , 0 ) ; y_step <= min( y + steps , grid_size - 1 ) ; y_step ++ ) {
              for( z_step = max( z - steps , 0 ) ; z_step <= min( z + steps , grid_size - 1 ) ; z_step ++ ) {

                if( (int)grid[gaddress(x_step,y_step,z_step,grid_size)] == 0 ) {

                  if( ( (float)( ( ( x_step - x ) * ( x_step - x ) ) + ( ( y_step - y ) * ( y_step - y ) ) + ( ( z_step - z ) * ( z_step - z ) ) ) * one_span * one_span ) < ( surface * surface ) ) at_surface = 1 ;

                }

              }
            }
          }

          if( at_surface == 0 ) grid[gaddress(x,y,z,grid_size)] = (fftw_real)internal_value ;

        }

      }
    }
  }

/************/

  return ;

}
