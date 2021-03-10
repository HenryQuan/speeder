#include <sys/time.h>
#include <substrate.h>

float speed = 0.1;

static int (*orig_gettimeofday)(struct timeval *tv, struct timezone *tz);
static int new_gettimeofday(struct timeval *tv, struct timezone *tz) {
	int ret = orig_gettimeofday(tv, tz);
	// 0 -> success, -1 -> failure
	if (ret == 0 && tv != NULL) {
		tv->tv_sec *= speed;
		tv->tv_usec *= speed;
	}

	return ret;
}

%ctor {
	MSHookFunction((void *)MSFindSymbol(NULL, "_gettimeofday"), (void *)new_gettimeofday, (void **)orig_gettimeofday);
}
