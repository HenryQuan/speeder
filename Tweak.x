#include "Tweak.h"

// 0 -> freeze, 0.5 -> half speed, 1 -> normal 
float speed = 1;
const int CONFIG_SIZE = 6;
float config[CONFIG_SIZE] = {1, 2, 3, 5, 0.5, 0};
int indx = 0;

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

@interface Menu : NSObject
+ (id)sharedInstance;
@end

@implementation Menu : NSObject

+ (id)sharedInstance {
    static Menu *menu;
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        menu = [[self alloc] init];
    });

    return menu;
}

- (UIView *)setupMenu {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, 30, 30)];
	button.backgroundColor = UIColor.redColor;
    [button addTarget:self action:@selector(onTapButton:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)onTapButton:(UIButton *)sender {
    if (indx < CONFIG_SIZE) {
		speed = config[indx];
		indx++;
	} else {
		indx = 0;
	}

    [sender setTitle:[NSString stringWithFormat:@"%.1f", speed] forState:UIControlStateNormal];
}

@end


static void didFinishLaunching(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef info) {
	delay(1)
	{
		UIViewController *controller = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
		[controller.view addSubview:[Menu.sharedInstance setupMenu]];
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
