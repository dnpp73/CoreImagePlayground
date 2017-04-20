#import <Foundation/Foundation.h>


@interface DPDiskUtil : NSObject

// File Info and FileSystem Info
+ (NSDictionary*)attributesOfItemPath:(NSString*)path;
+ (NSDictionary*)attributesOfFileSystem;

// create humanize string from bytes
+ (NSString*)humanizeStringForBytes:(int64_t)bytes; // Default digits is 0
+ (NSString*)humanizeStringForBytes:(int64_t)bytes digits:(int)digits;

// FileSystem Info
+ (int64_t)bytesOfTotalDiskSpace;
+ (int64_t)bytesOfFreeDiskSpace;
+ (int64_t)bytesOfUsedDiskSpace;

+ (NSString*)humanizeStringOfTotalDiskSpace;
+ (NSString*)humanizeStringOfFreeDiskSpace;
+ (NSString*)humanizeStringOfUsedDiskSpace;

// Directory Info(using BSD fts)
+ (int64_t)calculateContentsTotalBytesOfDirectoryPath:(NSString*)path usingBSDfts:(BOOL)usingBSDfts;

@end
