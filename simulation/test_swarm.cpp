/*

Copyright (c) 2008, Arvid Norberg
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in
      the documentation and/or other materials provided with the distribution.
    * Neither the name of the author nor the names of its
      contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
POSSIBILITY OF SUCH DAMAGE.

*/

#include "swarm_suite.hpp"
#include "test.hpp"

TORRENT_TEST(seed_mode)
{
	// with seed mode
	simulate_swarm(seed_mode);
}

TORRENT_TEST(plain)
{
	simulate_swarm();
}

TORRENT_TEST(suggest)
{
	// with suggest pieces
	simulate_swarm(suggest_read_cache);
}

TORRENT_TEST(utp)
{
	simulate_swarm(utp_only);
}

TORRENT_TEST(stop_start_download)
{
	simulate_swarm(stop_start_download | add_extra_peers);
}
TORRENT_TEST(stop_start_download_graceful)
{
	simulate_swarm(stop_start_download | graceful_pause | add_extra_peers);
}

TORRENT_TEST(stop_start_seed)
{
	simulate_swarm(stop_start_seed | add_extra_peers);
}

TORRENT_TEST(stop_start_seed_graceful)
{
	simulate_swarm(stop_start_seed | graceful_pause | add_extra_peers);
}

TORRENT_TEST(explicit_cache)
{
	// test explicit cache
	simulate_swarm(suggest_read_cache | explicit_cache);
}

TORRENT_TEST(shutdown)
{
	simulate_swarm(early_shutdown);
}

