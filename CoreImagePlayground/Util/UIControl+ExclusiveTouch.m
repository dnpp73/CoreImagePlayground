#import "UIControl+ExclusiveTouch.h"
#import <objc/runtime.h>

void swizzleInstanceMethod(Class class, SEL originalSelector, SEL alternativeSelector) {
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method alternativeMethod = class_getInstanceMethod(class, alternativeSelector);

    if (class_addMethod(class, originalSelector, method_getImplementation(alternativeMethod), method_getTypeEncoding(alternativeMethod))) {
        class_replaceMethod(class, alternativeSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, alternativeMethod);
    }
}

/*
void swizzleClassMethod(Class class, SEL originalSelector, SEL alternativeSelector) {
    class = object_getClass(class);

    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method alternativeMethod = class_getInstanceMethod(class, alternativeSelector);

    if (class_addMethod(class, originalSelector, method_getImplementation(alternativeMethod), method_getTypeEncoding(alternativeMethod))) {
        class_replaceMethod(class, alternativeSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, alternativeMethod);
    }
}
 */

@implementation UIControl (exclusiveTouch)

+ (void)load
{
    @autoreleasepool {
        swizzleInstanceMethod([self class], @selector(initWithCoder:), @selector(_initWithCoder:));
        swizzleInstanceMethod([self class], @selector(initWithFrame:), @selector(_initWithFrame:));
    }
}

- (instancetype)_initWithFrame:(CGRect)frame
{
    self = [self _initWithFrame:frame];
    if (self) {
        self.exclusiveTouch = YES;
    }
    return self;
}

- (instancetype)_initWithCoder:(NSCoder*)coder
{
    self = [self _initWithCoder:coder];
    if (self) {
        self.exclusiveTouch = YES;
    }
    return self;
}

@end
