#include <stdlib.h>
#include <unistd.h>
#include <substitute/substrate.h>
#include <Foundation/Foundation.h>

typedef struct CF_BRIDGED_TYPE(id) __SecTask *SecTaskRef;
__nullable CFStringRef SecTaskCopySigningIdentifier(SecTaskRef task, CFErrorRef *error);

CFTypeRef (*original_SecTaskCopyValueForEntitlement)(SecTaskRef task, CFStringRef entitlement, CFErrorRef _Nullable *error);
CFTypeRef hooked_SecTaskCopyValueForEntitlement(SecTaskRef task, CFStringRef entitlement, CFErrorRef _Nullable *error) {
  NSLog(@"hooked_SecTaskCopyValueForEntitlement++++");
  static CFSetRef set = NULL;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    CFStringRef set_values[] = {
      CFSTR("com.apple.security.get-task-allow"),
      CFSTR("com.apple.webinspector.allow"),
      // CFSTR("com.apple.private.webinspector.proxy-application"),
      CFSTR("com.apple.private.webinspector.allow-remote-inspection"),
      CFSTR("com.apple.private.webinspector.allow-carrier-remote-inspection"),
    };

    set = CFSetCreate(NULL, (const void **)set_values, sizeof(set_values) / sizeof(set_values[0]), &kCFTypeSetCallBacks);
  });

  CFStringRef identifier = SecTaskCopySigningIdentifier(task, NULL);
  if (CFSetContainsValue(set, entitlement)) {
    return kCFBooleanTrue;
  }
  return original_SecTaskCopyValueForEntitlement(task, entitlement, error);
}

void hook_webinspectord() {
  MSImageRef security = MSGetImageByName("/System/Library/Frameworks/Security.framework/Security");
  if (!security) {
    NSLog(@"Security framework not loaded, bail out");
    return;
  }

  MSHookFunction(
    MSFindSymbol(security, "_SecTaskCopyValueForEntitlement"),
    (void *)hooked_SecTaskCopyValueForEntitlement,
    (void **)&original_SecTaskCopyValueForEntitlement
  );
}

__attribute__((constructor))
void initialization() {
  const char *name = getprogname();
  NSLog(@"loaded in %s (%d)", name, getpid());

  if (strcmp(name, "webinspectord") == 0) {
    hook_webinspectord();
  }
}