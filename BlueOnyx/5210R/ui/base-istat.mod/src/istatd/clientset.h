/*
 *  Copyright 2010 William Tisäter. All rights reserved.
 * 
 *  Redistribution and use in source and binary forms, with or without
 *  modification, are permitted provided that the following conditions are met:
 *
 *    1.  Redistributions of source code must retain the above copyright
 *        notice, this list of conditions and the following disclaimer.
 *
 *    2.  Redistributions in binary form must reproduce the above copyright
 *        notice, this list of conditions and the following disclaimer in the
 *        documentation and/or other materials provided with the distribution.
 *
 *    3.  The name of the copyright holder may not be used to endorse or promote
 *        products derived from this software without specific prior written
 *        permission.
 *
 *  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDER ``AS IS'' AND ANY
 *  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 *  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 *  DISCLAIMED. IN NO EVENT SHALL WILLIAM TISÄTER BE LIABLE FOR ANY
 *  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 *  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 *  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 *  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 *  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */

#ifndef _CLIENTSET_H
#define _CLIENTSET_H

#include <vector>
#include <iostream>

#include "socketset.h"

class Client
{
	public:
		int ready;
		int socket;
		std::string name;
		std::string duuid;
		unsigned int sid_disk;
		unsigned int sid_fans;
		unsigned int sid_temp;
		
		void force_disk_refresh(void) { sid_disk++; }
		void force_fans_refresh(void) { sid_fans++; }
		void force_temp_refresh(void) { sid_temp++; }
};

class ClientSet
{
	public:
		void operator += (Client & _client);
		void authenticate(int _socket);
		Client *get_client(int _socket);
		int is_authenticated(const std::string & _duuid);
		void init_session(const std::string & _duuid, int _socket, const std::string & _name);
		int length(void);
		void clear_cache(void);
		void save_cache(void);
		void read_cache(const std::string & cachedir);
		
	private:
		std::string cache_dir;
		std::vector<Client> clients;
};

#endif
