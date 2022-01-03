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

/* Copied from generalised version in Kernighan and Ritchie */

/************/

int numerical_sort( const void *a , const void *b ){
  return a > b ;
}

/************/

void qsort_scores( struct Score *Scores , int left , int right ) {

  /* Variables */

  int	i , last ;

  /* Sub function */

  void swap( struct Score *Scores , int i , int j ) ;


  /* Neat code */

  if( left >= right ) return ;	/* have nothing to sort */

  swap( Scores , left , ( left + right ) / 2 ) ;

  last = left ;

  for( i = left + 1 ; i <= right ; i ++ ) {

    if( Scores[i].score > Scores[left].score ) {

      swap( Scores , ++ last , i ) ;

    } else {

      if( Scores[i].score == Scores[left].score ) {

        if( Scores[i].coord[1] > Scores[left].coord[1] ) {

          swap( Scores , ++ last , i ) ;

        } else {

          if( Scores[i].coord[1] == Scores[left].coord[1] ) {

            if( Scores[i].coord[2] > Scores[left].coord[2] ) {

              swap( Scores , ++ last , i ) ;

            } else {

              if( Scores[i].coord[2] == Scores[left].coord[2] ) {

                if( Scores[i].coord[3] > Scores[left].coord[3] ) {

                  swap( Scores , ++ last , i ) ;

                } else {

                  if( Scores[i].coord[3] == Scores[left].coord[3] ) {

                    if( Scores[i].angle[1] > Scores[left].angle[1] ) {

                      swap( Scores , ++ last , i ) ;

                    } else {

                      if( Scores[i].angle[1] == Scores[left].angle[1] ) {

                        if( Scores[i].angle[2] > Scores[left].angle[2] ) {

                          swap( Scores , ++ last , i ) ;

                        } else {

                          if( Scores[i].angle[2] == Scores[left].angle[2] ) {

                            if( Scores[i].angle[3] > Scores[left].angle[3] ) {

                              swap( Scores , ++ last , i ) ;

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

  swap( Scores , left , last ) ;

  qsort_scores( Scores , left , last - 1 ) ;

  qsort_scores( Scores , last + 1 , right ) ;

}

/************/

void qsort_rpscores( struct Score *Scores , int left , int right ) {

  /* Variables */

  int	i , last ;

  /* Sub function */

  void swap( struct Score *Scores , int i , int j ) ;


  /* Neat code */

  if( left >= right ) return ;	/* have nothing to sort */

  swap( Scores , left , ( left + right ) / 2 ) ;

  last = left ;

  for( i = left + 1 ; i <= right ; i ++ )

    if( Scores[i].rpscore > Scores[left].rpscore ) 

       swap( Scores , ++ last , i ) ;

  swap( Scores , left , last ) ;

  qsort_rpscores( Scores , left , last - 1 ) ;

  qsort_rpscores( Scores , last + 1 , right ) ;

}

/************/

void swap( struct Score *Scores , int i , int j ) {

  struct Score	Temp ;

  Temp = Scores[i] ;
  Scores[i] = Scores[j] ;
  Scores[j] = Temp ;

}
