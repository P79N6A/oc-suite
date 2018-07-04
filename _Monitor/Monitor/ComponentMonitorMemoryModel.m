//
//     ____              _____    _____    _____
//    / ___\   /\ /\     \_   \   \_  _\  /\  __\
//    \ \     / / \ \     / /\/    / /    \ \  _\_
//  /\_\ \    \ \_/ /  /\/ /_     / /      \ \____\
//  \____/     \___/   \____/    /__|       \/____/
//
//	Copyright BinaryArtists development team and other contributors
//
//	https://github.com/BinaryArtists/suite.great
//
//	Free to use, prefer to discuss!
//
//  Welcome!
//

#import "ComponentMonitorMemoryModel.h"

#pragma mark -

#define MAX_HISTORY	(128)

#pragma mark -

@implementation ComponentMonitorMemoryModel

@def_prop_assign( int64_t,			usedBytes );
@def_prop_assign( int64_t,			totalBytes );
@def_prop_strong( NSMutableArray *,	history );

@def_singleton( ComponentMonitorMemoryModel )

- (id)init {
	self = [super init];
	if ( self ) {
		self.usedBytes = 0;
		self.totalBytes = 0;
		self.history = [[NSMutableArray alloc] init];

		for ( NSUInteger i = 0; i < MAX_HISTORY; ++i ) {
			[self.history addObject:@(0)];
		}
	}
    
	return self;
}

- (void)dealloc {
	[self.history removeAllObjects];
	self.history = nil;
}

- (void)update {
	struct mstats stat = mstats();

	if ( 0 == stat.bytes_used ) {
		self.usedBytes = 0;
		self.totalBytes = 0;

		mach_port_t host_port;
		mach_msg_type_number_t host_size;
		vm_size_t pagesize;

		host_port = mach_host_self();
		host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
		host_page_size( host_port, &pagesize );

		vm_statistics_data_t vm_stat;
		kern_return_t ret = host_statistics( host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size );
		
		if ( KERN_SUCCESS == ret ) {
			natural_t mem_used = (vm_stat.active_count + vm_stat.inactive_count + vm_stat.wire_count) * (unsigned int)pagesize;
			natural_t mem_free = vm_stat.free_count * (unsigned int)pagesize;
			natural_t mem_total = mem_used + mem_free;

			self.usedBytes = mem_used;
			self.totalBytes = mem_total;
		}
	} else {
		self.usedBytes = stat.bytes_used;
		self.totalBytes = [[NSProcessInfo processInfo] physicalMemory];
	}
	
	[self.history addObject:[NSNumber numberWithFloat:self.usedBytes]];
	[self.history keepTail:MAX_HISTORY];
	
//	PERF( @"Memory, used %d, total %d", self.used, self.total );
}

@end
