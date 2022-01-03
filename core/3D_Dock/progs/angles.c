/*
This file is part of ftdock, a program for rigid-body protein-protein docking 
Copyright (C) 1997-2000 Henry Gabb/Gidon Moont

Biomolecular Modelling Laboratory
Imperial Cancer Research Fund
44 Lincoln's Inn Fields
London WC2A 3PX

+44 (0)20 7269 3565
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

struct Angle generate_global_angles( int angle_step ) {

/************/

  /* Counters */

  int		n ;

  /* Variables */

  int		z_twist , theta , phi ;
  int		phi_step_for_this_theta ;

  /* What the data is going into */
  struct Angle		Angles ;

/************/

  if( ( Angles.z_twist = ( int * ) malloc ( MAX_ROTATIONS * sizeof( int ) ) ) &&
      ( Angles.theta   = ( int * ) malloc ( MAX_ROTATIONS * sizeof( int ) ) ) &&
      ( Angles.phi     = ( int * ) malloc ( MAX_ROTATIONS * sizeof( int ) ) ) ) {
  } else {
    GENERAL_MEMORY_PROBLEM
  }

  n = 0 ;

  theta = 0 ;
  phi = 0 ;

/************/

  if( ( 180 % angle_step ) != 0 ) {

    printf( "Bad angle step chosen\nPlease choose a value which is an integer factor of 180\nDying\n\n" ) ;
    exit( EXIT_FAILURE ) ;

  }

  if( angle_step < 9 ) {

    printf( "Sorry, but I refuse to do so many rotations (more than 70 thousand).  Think again.\nIf you insist then you will have to check the byte size of an integer on your machine and possibly change all my ints to longs\nDying\n\n" ) ;
    exit( EXIT_FAILURE ) ;

  }

/************/

  for( z_twist = 0 ; z_twist < 360 ; z_twist += angle_step ) {

    n ++ ;

    Angles.z_twist[n] = z_twist ;
    Angles.theta[n]   = 0 ;
    Angles.phi[n]     = 0 ;

  }

  for( theta = angle_step ; theta < 180 ; theta += angle_step ) {

    phi_step_for_this_theta = 57.29578 * acos( ( cos( 0.017453293 * angle_step ) - ( cos( 0.017453293 * theta ) * cos( 0.017453293 * theta ) ) ) / ( sin( 0.017453293 * theta ) * sin( 0.017453293 * theta ) ) ) ;

    while( ( 360 % phi_step_for_this_theta ) != 0 ) phi_step_for_this_theta -- ;

    for( phi = 0 ; phi < 360 ; phi += phi_step_for_this_theta ) {

      for( z_twist = 0 ; z_twist < 360 ; z_twist += angle_step ) {

        n ++ ;

        Angles.z_twist[n] = z_twist ;
        Angles.theta[n]   = theta ;
        Angles.phi[n]     = phi ;

      }

    }

  }

  for( z_twist = 0 ; z_twist < 360 ; z_twist += angle_step ) {

    n ++ ;

    Angles.z_twist[n] = z_twist ;
    Angles.theta[n]   = 180 ;
    Angles.phi[n]     = 0 ;

  }

/************/

  if( n >= MAX_ROTATIONS ) {

    printf( "You have exceeded the MAX_ROTATIONS constant.\nEither choose a larger angle_step or recompile after editing structures.h\nDying\n\n" ) ;
    exit( EXIT_FAILURE ) ;

  }

  if( ( Angles.z_twist = ( int * ) realloc ( Angles.z_twist  , ( 1 + n ) * sizeof( int ) ) ) &&
      ( Angles.theta   = ( int * ) realloc ( Angles.theta    , ( 1 + n ) * sizeof( int ) ) ) &&
      ( Angles.phi     = ( int * ) realloc ( Angles.phi      , ( 1 + n ) * sizeof( int ) ) ) ) {
  } else {
    GENERAL_MEMORY_PROBLEM
  }

  Angles.n = n ;

/************/

  return Angles ;

}



/************************/



struct Angle generate_range_of_angles( int angle_step , int angle_range , int z_twist , int theta , int phi ) {

/************/

  /* Counters */

  int		n ;

  /* Variables */

  int		z_twist_step , theta_step , phi_step ;
  int		phi_step_for_this_theta ;
  int		this_z_twist_step , this_phi_step ;

  /* What the data is going into */
  struct Angle		Angles ;

/************/

  if( ( Angles.z_twist = ( int * ) malloc ( MAX_ROTATIONS * sizeof( int ) ) ) &&
      ( Angles.theta   = ( int * ) malloc ( MAX_ROTATIONS * sizeof( int ) ) ) &&
      ( Angles.phi     = ( int * ) malloc ( MAX_ROTATIONS * sizeof( int ) ) ) ) {
  } else {
    GENERAL_MEMORY_PROBLEM
  }

/************/

  n = 0 ;

  if( angle_range != 0 ) angle_range = angle_step * (int)( angle_range / angle_step ) ;

/************/

  phi_step_for_this_theta = 57.29578 * acos( ( cos( 0.017453293 * angle_step ) - ( cos( 0.017453293 * theta ) * cos( 0.017453293 * theta ) ) ) / ( sin( 0.017453293 * theta ) * sin( 0.017453293 * theta ) ) ) ;

  while( ( 360 % phi_step_for_this_theta ) != 0 ) phi_step_for_this_theta -- ;

/************/

  for( z_twist_step = z_twist - angle_range ; z_twist_step <= z_twist + angle_range ; z_twist_step += angle_step ) {

    this_z_twist_step = z_twist_step ;

    if( this_z_twist_step >= 360 ) this_z_twist_step -= 360 ;
    if( this_z_twist_step < 0 ) this_z_twist_step += 360 ;

    n ++ ;

    Angles.z_twist[n] = this_z_twist_step ;
    Angles.theta[n]   = theta ;
    Angles.phi[n]     = phi ;

  }

  for( theta_step = max( theta - angle_range , 0 ) ; theta_step <= min( theta + angle_range , 180 ) ; theta_step += angle_step ) {

    if( theta_step != theta ) {

      n ++ ;

      Angles.z_twist[n] = z_twist ;
      Angles.theta[n]   = theta_step ;
      Angles.phi[n]     = phi ;

    }

  }

  for( phi_step = phi - angle_range ; phi_step <= phi + angle_range ; phi_step += angle_step ) {

    if( phi_step != phi ) {

      this_phi_step = phi_step ;

      if( this_phi_step >= 360 ) this_phi_step -= 360 ;
      if( this_phi_step < 0 ) this_phi_step += 360 ;

      n ++ ;

      Angles.z_twist[n] = z_twist ;
      Angles.theta[n]   = theta ;
      Angles.phi[n]     = this_phi_step ;

    }

  }

/************/

  if( ( Angles.z_twist = ( int * ) realloc ( Angles.z_twist  , ( 1 + n ) * sizeof( int ) ) ) &&
      ( Angles.theta   = ( int * ) realloc ( Angles.theta    , ( 1 + n ) * sizeof( int ) ) ) &&
      ( Angles.phi     = ( int * ) realloc ( Angles.phi      , ( 1 + n ) * sizeof( int ) ) ) ) {
  } else {
    GENERAL_MEMORY_PROBLEM
  }

  Angles.n = n ;

/************/

  return Angles ;

}
