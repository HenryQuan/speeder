
#include <sys/time.h>
#include <substrate.h>
#include <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

#define delay(sec) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, sec * NSEC_PER_SEC), dispatch_get_main_queue(), ^
#define log(any) NSLog(@"speeder: %@", any)
