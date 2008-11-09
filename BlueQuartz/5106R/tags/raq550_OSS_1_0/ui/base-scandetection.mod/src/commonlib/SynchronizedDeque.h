/*

$header$

                   Site:  Progressive Systems, Inc.

                Module :  $Source: /home/cvs/base-scandetection.mod/src/commonlib/SynchronizedDeque.h,v $
              Revision :  $Revision: 1.1 $

               Package :  Phoenix Adaptive Firewall for Unix

         Creation Date :  20-Nov-2000
    Originating Author :  Brian Adkins

      Last Modified by :  $Author: jthrowe $ 
    Date Last Modified :  $Date: 2001/09/18 16:59:37 $

   **********************************************************************

   Copyright (c) 2000 Progressive Systems Inc.
   All rights reserved.

   This code is confidential property of Progressive Systems Inc.  The
   algorithms, methods and software used herein may not be duplicated or
   disclosed to any party without the express written consent from
   Progressive Systems Inc.

   Progressive Systems Inc. makes no representations concerning either
   the merchantability of this software or the suitability of this
   software for any particular purpose.

   These notices must be retained in any copies of any part of this
   documentation and/or software.

   ********************************************************************** */

#ifndef _SYNCHRONIZEDDEQUE_H_
#define _SYNCHRONIZEDDEQUE_H_

#include <deque>
#include "Thread.h"

using namespace std;

template <class T> class SynchronizedDeque : protected deque<T>
{
 private:
    mutable Mutex mutex;

    SynchronizedDeque (const SynchronizedDeque&);
    SynchronizedDeque& operator=(const SynchronizedDeque&);
    
 public:
    SynchronizedDeque() : deque<T>() {}
    ~SynchronizedDeque () {}

    reference front()
	{
	    MutexLock lock(mutex);
	    return deque<T>::front();
	}

    const_reference front() const
	{
	    MutexLock lock(mutex);
	    return deque<T>::front();
	}

    void pop_front()
	{
	    MutexLock lock(mutex);
	    deque<T>::pop_front();
	}

    void push_back(const T& x)
	{
	    MutexLock lock(mutex);
	    deque<T>::push_back(x);
	}

    size_type size() const
	{
	    MutexLock lock(mutex);
	    return deque<T>::size();
	}
};

#endif /* #ifndef _SYNCHRONIZEDDEQUE_H_ */
/* Copyright (c) 2003 Sun Microsystems, Inc. All  Rights Reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met: 
 * 
 * -Redistribution of source code must retain the above copyright notice, this
 * list of conditions and the following disclaimer.
 * 
 * -Redistribution in binary form must reproduce the above copyright notice,
 * this list of conditions and the following disclaimer in the documentation
 * and/or other materials provided with the distribution. 
 *
 * Neither the name of Sun Microsystems, Inc. or the names of contributors may
 * be used to endorse or promote products derived from this software without 
 * specific prior written permission.

 * This software is provided "AS IS," without a warranty of any kind. ALL EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR NON-INFRINGEMENT, ARE HEREBY EXCLUDED. SUN MICROSYSTEMS, INC. ("SUN") AND ITS LICENSORS SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING, MODIFYING OR DISTRIBUTING THIS SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL SUN OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT OF THE USE OF OR INABILITY TO USE THIS SOFTWARE, EVEN IF SUN HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 * 
 * You acknowledge that  this software is not designed or intended for use in the design, construction, operation or maintenance of any nuclear facility.
 */
