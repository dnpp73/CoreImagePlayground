#import "DPDiskUtil.h"
#include <sys/types.h>
#include <sys/stat.h>
#include <fts.h>


@interface DPDiskUtil ()

@end


@implementation DPDiskUtil

#pragma mark - Formatter

+ (NSString*)humanizeStringForBytes:(int64_t)bytes // public
{
    return [self humanizeStringForBytes:bytes digits:0];
}

+ (NSString*)humanizeStringForBytes:(int64_t)bytes digits:(int)digits // public
{
    NSString* formatted;
    Float64 b = (Float64)bytes;
    int  unit = 1024;
    Float64 k = b / (Float64)unit;
    Float64 m = b / (Float64)(unit*unit);
    Float64 g = b / (Float64)(unit*unit*unit);
    NSString* format = [NSString stringWithFormat:@"%%.%df ", digits];
    if (g >= 1.0) {
        format = [format stringByAppendingString:@"GB"];
        formatted = [NSString stringWithFormat:format, g];
    }
    else if (m >= 1.0) {
        format = [format stringByAppendingString:@"MB"];
        formatted = [NSString stringWithFormat:format, m];
    }
    else {
        format = [format stringByAppendingString:@"KB"];
        formatted = [NSString stringWithFormat:format, k];
    }
    return formatted;
}

#pragma mark - Common

+ (NSDictionary*)attributesOfItemPath:(NSString*)path // public
{
    return [[NSFileManager defaultManager] attributesOfItemAtPath:path error:nil];
}

+ (NSDictionary*)attributesOfFileSystemForPath:(NSString*)path
{
    return [[NSFileManager defaultManager] attributesOfFileSystemForPath:path error:nil];
}

+ (NSDictionary*)homeDirectoryAttributes
{
    return [self attributesOfFileSystemForPath:NSHomeDirectory()];
}

+ (NSDictionary*)attributesOfFileSystem // public
{
    return [self homeDirectoryAttributes];
}

+ (int64_t)homeDirectoryValueForKey:(NSString*)key
{
    return [[[self homeDirectoryAttributes] objectForKey:key] longLongValue];
}

#pragma mark - Public int64_t bytes

+ (int64_t)bytesOfTotalDiskSpace
{
    return [self homeDirectoryValueForKey:NSFileSystemSize];
}

+ (int64_t)bytesOfFreeDiskSpace
{
    return [self homeDirectoryValueForKey:NSFileSystemFreeSize];
}

+ (int64_t)bytesOfUsedDiskSpace
{
    return [self bytesOfTotalDiskSpace] - [self bytesOfFreeDiskSpace];
}

#pragma mark - Public Humanize

+ (NSString*)humanizeStringOfTotalDiskSpace
{
    return [self humanizeStringForBytes:[self bytesOfTotalDiskSpace]];
}

+ (NSString*)humanizeStringOfFreeDiskSpace
{
    return [self humanizeStringForBytes:[self bytesOfFreeDiskSpace]];
}

+ (NSString*)humanizeStringOfUsedDiskSpace
{
    return [self humanizeStringForBytes:[self bytesOfUsedDiskSpace]];
}

#pragma mark -

+ (int64_t)calculateContentsTotalBytesOfDirectoryPath:(NSString*)path usingBSDfts:(BOOL)usingBSDfts // public
{
    if (usingBSDfts) {
        char c_path[path.length];
        strcpy(c_path, [path cStringUsingEncoding:NSUTF8StringEncoding]);
        int64_t size = 0;
        FTS*    fts;
        FTSENT* entry;
        char* paths[] = {
            c_path,
            NULL
        };
        fts = fts_open(paths, 0, NULL);
        while ((entry = fts_read(fts))) {
            if (entry->fts_info & FTS_DP || entry->fts_level == 0) {
                // ignore post-order
                continue;
            }
            if (entry->fts_info & FTS_F) {
                size += entry->fts_statp->st_size;
            }
        }
        fts_close(fts);
        return size;
    }
    else {
        NSFileManager* fm = [NSFileManager defaultManager];
        int64_t size = 0;
        for (NSString* fileName in [fm enumeratorAtPath:path]) {
            NSDictionary* attr = [fm attributesOfItemAtPath:[path stringByAppendingPathComponent:fileName] error:nil];
            if ([attr[NSFileType] isEqualToString:NSFileTypeRegular]) {
                size += [attr[NSFileSize] longLongValue];
            }
        }
        return size;
    }
}

@end
