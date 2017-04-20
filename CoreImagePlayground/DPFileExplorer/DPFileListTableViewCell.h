#import <UIKit/UIKit.h>


extern NSString* const DPFileListTableViewCellIdentifier;


@interface DPFileListTableViewCell : UITableViewCell

@property (nonatomic) NSFileWrapper* fileWrapper;

+ (UINib*)nibForRegisterTableView;

@end
