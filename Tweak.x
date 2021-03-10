#include <sys/time.h>
#include <substrate.h>
#include <Foundation/Foundation.h>

float speed = 0.1;

static int (*orig_gettimeofday)(struct timeval *tv, struct timezone *tz);
static int new_gettimeofday(struct timeval *tv, struct timezone *tz) {
	NSLog(@"Speeder: new function");
	int error = orig_gettimeofday(tv, tz);
	NSLog(@"Speeder: called old function");
	// 0 -> success, -1 -> failure
	if (error == 0 && tv != NULL) {
		NSLog(@"Speeder: success");
		tv->tv_sec *= speed;
		tv->tv_usec *= speed;
	} else {
		NSLog(@"Speeder: failure");
		tv->tv_sec *= speed;
		tv->tv_usec *= speed;
	}

	return error;
}

%ctor {
	MSImageRef libc = MSGetImageByName("libstdc++.dylib");
	NSLog(@"Speeder: Getting image ref");
	if (libc != NULL) {
		NSLog(@"Speeder: image ref is all goo");
		MSHookFunction((void *)MSFindSymbol(NULL, "_gettimeofday"), (void *)new_gettimeofday, (void **)orig_gettimeofday);
		NSLog(@"Speeder: hook completed");
	}

	NSLog(@"Speeder: try hook");
	MSHookFunction((void *)MSFindSymbol(NULL, "_gettimeofday"), (void *)new_gettimeofday, (void **)&orig_gettimeofday);
	NSLog(@"Speeder: hook done");
}
