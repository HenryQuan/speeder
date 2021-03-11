#include <sys/time.h>
#include <substrate.h>

float speed = 0.5;
static struct timeval *base = NULL;

static int (*_gettimeofday)(struct timeval *, struct timezone *);
static int new_gettimeofday(struct timeval *tv, struct timezone *tz) {
	int val = _gettimeofday(tv, tz);
	// 0 -> success, -1 -> failure
	if (val == 0 && tv != NULL) {
		// setup the base time
		if (base == NULL) {
			base = malloc(sizeof(struct timeval));
			*base = *tv;
			return val;
		}
		
		// time = base + (current - base) * speed
		long int diff = (tv->tv_sec - base->tv_sec) * speed;
		tv->tv_sec = base->tv_sec + diff;
	}

	return val;
}

%ctor {
	MSHookFunction((void *)MSFindSymbol(NULL, "_gettimeofday"), (void *)new_gettimeofday, (void **)&_gettimeofday);
}
