#import "DPFileListTableViewCell.h"
#import "DPDiskUtil.h"


NSString* const DPFileListTableViewCellIdentifier = @"DPFileListTableViewCellIdentifier";


@interface DPFileListTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel* kindLabel;
@property (weak, nonatomic) IBOutlet UILabel* nameLabel;
@property (weak, nonatomic) IBOutlet UILabel* sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel* aclLabel;
@property (weak, nonatomic) IBOutlet UILabel* ownerLabel;
@property (weak, nonatomic) IBOutlet UILabel* createdAtLabel;
@property (weak, nonatomic) IBOutlet UILabel* updateAtLabel;
@end


@implementation DPFileListTableViewCell

- (void)setFileWrapper:(NSFileWrapper*)fileWrapper
{
    if (_fileWrapper != fileWrapper) {
        _fileWrapper = fileWrapper;
        
        self.nameLabel.text = fileWrapper.filename;
        self.kindLabel.text = fileWrapper.isDirectory ? @"📁" : @"📄";
        
        /* 
         fileWrapper.fileAttributes
         {
         NSFileCreationDate = "2015-03-06 04:27:35 +0000";
         NSFileExtensionHidden = 0;
         NSFileGroupOwnerAccountID = 501;
         NSFileGroupOwnerAccountName = mobile;
         NSFileModificationDate = "2015-03-06 04:27:35 +0000";
         NSFileOwnerAccountID = 501;
         NSFileOwnerAccountName = mobile;
         NSFilePosixPermissions = 493; 493(10) -> 0755(8)
         NSFileReferenceCount = 4;
         NSFileSize = 136;
         NSFileSystemFileNumber = 7407883;
         NSFileSystemNumber = 16777220;
         NSFileType = NSFileTypeDirectory;
         }
         */
        NSDictionary* attr = fileWrapper.fileAttributes;
        self.sizeLabel.text      = fileWrapper.isDirectory ? @"" : [DPDiskUtil humanizeStringForBytes:[attr[NSFileSize] longLongValue] digits:2];
        self.aclLabel.text       = [NSString stringWithFormat:@"%o", [attr[NSFilePosixPermissions] intValue]];
        self.ownerLabel.text     = [NSString stringWithFormat:@"%@:%@", attr[NSFileOwnerAccountName], attr[NSFileGroupOwnerAccountName]];
        self.createdAtLabel.text = [[[self class] dateFormatter] stringFromDate:attr[NSFileCreationDate]];
        self.updateAtLabel.text  = [[[self class] dateFormatter] stringFromDate:attr[NSFileModificationDate]];
        
        self.accessoryType = (fileWrapper.isDirectory) ? UITableViewCellAccessoryDisclosureIndicator : UITableViewCellAccessoryNone;
        self.editingAccessoryType = UITableViewCellAccessoryNone;
    }
}

+ (UINib*)nibForRegisterTableView
{
    NSString* nibName = NSStringFromClass([self class]);
    NSBundle* bundle  = [NSBundle bundleForClass:[self class]];
    return [UINib nibWithNibName:nibName bundle:bundle];
}

+ (NSDateFormatter*)dateFormatter
{
    static NSDateFormatter* dateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.locale   = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        dateFormatter.dateFormat = @"yy-MM-dd HH:mm:ss";
    });
    return dateFormatter;
}

@end
