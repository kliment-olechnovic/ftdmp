/*
 * Copyright (c) 1997-1999 Massachusetts Institute of Technology
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */

/* Note: this header file *must* be the first thing in this file,
   due to AIX alloca lossage. */
#include <fftw_threads-int.h>

/* Distribute a loop from 0 to loopmax-1 over nthreads threads.
   proc(d) is called to execute a block of iterations from d->min
   to d->max-1.  d->thread_num indicate the number of the thread
   that is executing proc (from 0 to nthreads-1), and d->data is
   the same as the data parameter passed to fftw_thread_spawn_loop.

   This function returns only when all the threads have completed. */
void fftw_thread_spawn_loop(int loopmax, int nthreads,
			    fftw_loop_function proc, void *data)
{
     int block_size;

     if (!nthreads)
	  nthreads = 1;

     /* Choose the block size and number of threads in order to (1)
        minimize the critical path and (2) use the fewest threads that
        achieve the same critical path (to minimize overhead).
        e.g. if loopmax is 5 and nthreads is 4, we should use only 3
        threads with block sizes of 2, 2, and 1. */
     block_size = (loopmax + nthreads - 1) / nthreads;
     nthreads = (loopmax + block_size - 1) / block_size;

     if (nthreads <= 1) {
	  fftw_loop_data d;
	  d.min = 0; d.max = loopmax;
	  d.thread_num = 0;
	  d.data = data;
	  proc(&d);
     }
     else {
	  fftw_loop_data *d;
	  fftw_thread_id *tid;
	  int i;
	  
	  d = (fftw_loop_data *) ALLOCA(sizeof(fftw_loop_data) * nthreads);
	  tid = (fftw_thread_id *) 
	       ALLOCA(sizeof(fftw_thread_id) * (--nthreads));
	  
	  for (i = 0; i < nthreads; ++i) {
	       d[i].max = (d[i].min = i * block_size) + block_size;
	       d[i].thread_num = i;
	       d[i].data = data;
	       fftw_thread_spawn(&tid[i],
				 (fftw_thread_function) proc, (void *) &d[i]);
	  }
	  
	  d[i].min = i * block_size;
	  d[i].max = loopmax;
	  d[i].thread_num = i;
	  d[i].data = data;
	  proc(&d[i]);
	  
	  for (i = 0; i < nthreads; ++i)
	       fftw_thread_wait(tid[i]);
     
	  ALLOCA_CLEANUP(tid);
	  ALLOCA_CLEANUP(d);
     }
}

#ifdef FFTW_USING_POSIX_THREADS

static pthread_attr_t fftw_pthread_attributes; /* attrs for POSIX threads */
pthread_attr_t *fftw_pthread_attributes_p = NULL;

/* AIX uses a broken name for this pthread attribute constant: */
#  ifdef HAVE_PTHREAD_CREATE_UNDETACHED
#    define FFTW_PTHREAD_JOINABLE_ATTR PTHREAD_CREATE_UNDETACHED /* AIX */
#  else
#    define FFTW_PTHREAD_JOINABLE_ATTR PTHREAD_CREATE_JOINABLE   /* normal */
#  endif

#endif /* FFTW_USING_POSIX_THREADS */

/* fftw_threads_init does any initialization that is necessary to use
   threads.  It must be called before calling fftw_threads or
   fftwnd_threads. 
   
   Returns 0 if successful, and non-zero if there is an error.
   Do not call any fftw_threads routines if fftw_threads_init
   is not successful! */

int fftw_threads_init(void)
{
#ifdef FFTW_USING_POSIX_THREADS
     /* Set the thread creation attributes as necessary.  If we don't
	change anything, just use the default attributes (NULL). */
     int err, attr, attr_changed = 0;

     err = pthread_attr_init(&fftw_pthread_attributes); /* set to defaults */
     if (err) return err;

     /* Make sure that threads are joinable!  (they aren't on AIX) */
     err = pthread_attr_getdetachstate(&fftw_pthread_attributes, &attr);
     if (err) return err;
     if (attr != FFTW_PTHREAD_JOINABLE_ATTR) {
	  err = pthread_attr_setdetachstate(&fftw_pthread_attributes,
					    FFTW_PTHREAD_JOINABLE_ATTR);
	  if (err) return err;
	  attr_changed = 1;
     }

     if (attr_changed)  /* we aren't using the defaults */
	  fftw_pthread_attributes_p = &fftw_pthread_attributes;
     else {
	  fftw_pthread_attributes_p = NULL;  /* use default attributes */
	  err = pthread_attr_destroy(&fftw_pthread_attributes);
	  if (err) return err;
     }
#endif /* FFTW_USING_POSIX_THREADS */

#ifdef FFTW_USING_MACOS_THREADS
     /* Must use MPAllocate and MPFree instead of malloc and free: */
     if (MPLibraryIsLoaded()) {
	  fftw_malloc_hook = MPAllocate;
	  fftw_free_hook = MPFree;
     }
#endif /* FFTW_USING_MACOS_THREADS */

     return 0; /* no error */
}
