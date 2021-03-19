#include "Tweak.h"

// 0 -> freeze, 0.5 -> half speed, 1 -> normal 
float speed = 0.5;
static struct timeval *base = NULL;

static int (*orig_gettimeofday)(struct timeval *, struct timezone *);
static int new_gettimeofday(struct timeval *tv, struct timezone *tz) {
	int val = orig_gettimeofday(tv, tz);
	// 0 -> success, -1 -> failure
	if (val == 0 && tv != NULL) {
		// setup the base time
		if (base == NULL) {
			base = malloc(sizeof(struct timeval));
			*base = *tv;
			return val;
		}
		
		// time = base + (current - base) * speed
		long int diffSec = (tv->tv_sec - base->tv_sec) * speed;
		long int diffUsec = (tv->tv_usec - base->tv_usec) * speed;
		tv->tv_sec = base->tv_sec + diffSec;
		// it is necessary to update usec to make it very smoother
		tv->tv_usec = base->tv_usec + diffUsec;
	}

	return val;
}

%hook UIViewController
- (void)onTapButton {
	log(@"touch event");
}
%end

static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	delay(3)
	{
		UIViewController *controller = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
		UIButton *menu = [[UIButton alloc] initWithFrame:CGRectMake(0, 20, 50, 50)];
		menu.backgroundColor = UIColor.redColor;
		[menu addTarget:controller action:@selector(onTapButton) forControlEvents:UIControlEventTouchUpInside];
		[controller.view addSubview:menu];
	});
}

%ctor {
	// Listen for app launches
	CFNotificationCenterAddObserver(CFNotificationCenterGetLocalCenter(), 
			NULL, &didFinishLaunching, (CFStringRef)UIApplicationDidFinishLaunchingNotification, 
			NULL, CFNotificationSuspensionBehaviorDeliverImmediately);

	MSHookFunction((void *)MSFindSymbol(NULL, "_gettimeofday"), (void *)new_gettimeofday, (void **)&orig_gettimeofday);

	// for fishhook
	// rebind_symbols((struct rebinding[1]){
	// 	{"gettimeofday", (void *)new_gettimeofday, (void **)&orig_gettimeofday},
	// }, 1);
}
