#import "DPFileListViewController.h"
#import "DPFileListTableViewCell.h"


@interface DPFileListViewController () <UIDocumentInteractionControllerDelegate>
{
    UIRefreshControl* _refreshControl;
    
    NSMutableArray<NSURL*>* _fileURLs;
    NSMutableDictionary<NSURL*, NSFileWrapper*>* _fileWrappers;
    
    UIDocumentInteractionController* _documentInteractionController;
    
    UIBarButtonItem* _mkdirButton;
}
@property (nonatomic, copy) NSArray<NSURL*>* fileURLs;
@property NSURL* parentFileURL;
@end


@implementation DPFileListViewController

#pragma mark - Initializer

- (id)initWithNibName:(NSString*)nibNameOrNil bundle:(NSBundle*)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        _fileWrappers = [NSMutableDictionary<NSURL*, NSFileWrapper*> dictionary];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Editing
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    // RefreshControl
    _refreshControl = [[UIRefreshControl alloc] init];
    [_refreshControl addTarget:self action:@selector(valueChangedRefreshControl:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = _refreshControl;
    
    // Custom TableViewCell
    [self.tableView registerNib:[DPFileListTableViewCell nibForRegisterTableView] forCellReuseIdentifier:DPFileListTableViewCellIdentifier];
    
    // for mkdir
    _mkdirButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(actionForMkdirBarButtonItem:)];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    for (NSIndexPath* indexPath in self.tableView.indexPathsForSelectedRows) {
        [self.tableView deselectRowAtIndexPath:indexPath animated:animated];
    }
}

#pragma mark - Accessor

- (NSArray*)fileURLs
{
    return _fileURLs.copy;
}

- (void)setFileURLs:(NSArray<NSURL*>*)fileURLs
{
    if ([_fileURLs isEqualToArray:fileURLs] == NO) {
        for (id obj in fileURLs) {
            if ([obj isKindOfClass:[NSURL class]] == NO || [obj isFileURL] == NO) {
                [NSException raise:@"TypeException" format:@"each fileURL object must be NSFileURL instance. and must be isFileURL==YES"];
            }
        }
        
        _fileURLs = fileURLs.mutableCopy;
        
        [_fileWrappers removeAllObjects];
        for (NSURL* url in fileURLs) {
            NSError* error;
            NSFileWrapper* fw = [[NSFileWrapper alloc] initWithURL:url options:NSFileWrapperReadingWithoutMapping error:&error];
            if (error) {
                NSLog(@"error\n%@", error);
            }
            if (fw) {
                _fileWrappers[url] = fw;
            }
        }
        
        if (self.isViewLoaded) {
            [self.tableView reloadData];
        }
    }
}

#pragma mark - UIRefreshControl Action

- (void)valueChangedRefreshControl:(UIRefreshControl*)refreshControl
{
    if (self.editing) {
        [refreshControl endRefreshing];
        return;
    }
    
    NSArray<NSURL*>* fileURLs;
    if (self.parentFileURL) {
        NSError* error;
        fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:self.parentFileURL includingPropertiesForKeys:nil options:0 error:&error];
        if (error) {
            [self showErrorAlertWithError:error];
        }
    } else {
        fileURLs = [[self class] rootFileURLs];
    }
    self.fileURLs = fileURLs;
    [refreshControl endRefreshing];
}

#pragma mark - UIBarButtonItem Action

- (void)actionForMkdirBarButtonItem:(UIBarButtonItem*)barButtonItem
{
    [self showMkdirAlert];
}

#pragma mark - UIAlertController Util

- (void)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
         cancelButtonTitle:(NSString*)cancelButtonTitle
            okButtonTitile:(NSString*)okButtonTitle
              useTextInput:(BOOL)useTextInput
    initialTextInputString:(NSString*)initialTextInputString
                 alertKind:(NSString*)alertKind
                 indexPath:(NSIndexPath*)indexPath
{
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:cancelButtonTitle style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
        if ([alertKind isEqualToString:@"mkdir"]) {
        }
        else if ([alertKind isEqualToString:@"delete"]) {
            [self canceledDeleteAlertWithIndexPath:indexPath];
        }
        else if ([alertKind isEqualToString:@"rename"]) {
            [self canceledRenameAlertWithIndexPath:indexPath];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:okButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action){
        if ([alertKind isEqualToString:@"mkdir"]) {
            NSString* newDirectoryName = alertController.textFields[0].text;
            [self pushedMkdirAlertButtonWithNewDirectoryName:newDirectoryName];
        }
        else if ([alertKind isEqualToString:@"delete"]) {
            [self pushedDeleteAlertButtonWithIndexPath:indexPath];
        }
        else if ([alertKind isEqualToString:@"rename"]) {
            NSString* newFileName = alertController.textFields[0].text;
            [self pushedRenameAlertButtonWithIndexPath:indexPath newFileName:newFileName];
        }
    }]];
    if (useTextInput) {
        [alertController addTextFieldWithConfigurationHandler:^(UITextField* textField){
            textField.text = initialTextInputString;
        }];
    }
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showMkdirAlert
{
    [self showAlertWithTitle:@"mkdir"
                     message:@"enter new directory name."
           cancelButtonTitle:@"Cancel"
              okButtonTitile:@"mkdir"
                useTextInput:YES
      initialTextInputString:nil
                   alertKind:@"mkdir"
                   indexPath:nil];
}

- (void)showDeleteAlertWithIndexPath:(NSIndexPath*)indexPath
{
    [self showAlertWithTitle:@"Are you sure?"
                     message:@"Delete file?"
           cancelButtonTitle:@"Cancel"
              okButtonTitile:@"Delete"
                useTextInput:NO
      initialTextInputString:nil
                   alertKind:@"delete"
                   indexPath:indexPath];
}

- (void)showRenameAlertWithIndexPath:(NSIndexPath*)indexPath
{
    NSURL*    fileURL = _fileURLs[indexPath.row];
    NSString* initialTextInputString = fileURL.pathComponents.lastObject;
    [self showAlertWithTitle:@"Rename"
                     message:@"enter new file name."
           cancelButtonTitle:@"Cancel"
              okButtonTitile:@"Rename"
                useTextInput:YES
      initialTextInputString:initialTextInputString
                   alertKind:@"rename"
                   indexPath:indexPath];
}

- (void)showErrorAlertWithError:(NSError*)error
{
    NSLog(@"error\n%@", error);
    [self showAlertWithTitle:@"Error!"
                     message:error.localizedDescription
           cancelButtonTitle:@"OK"
              okButtonTitile:nil
                useTextInput:NO
      initialTextInputString:nil
                   alertKind:nil
                   indexPath:nil];
}

#pragma mark - Editing

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    [self.navigationItem setHidesBackButton:editing animated:animated];
    self.refreshControl = (editing ? nil : _refreshControl);
    [self.navigationItem setLeftBarButtonItem:(editing && self.parentFileURL ? _mkdirButton : nil) animated:animated];
    for (UITableViewCell* cell in self.tableView.visibleCells) {
        [cell setEditing:editing animated:animated];
    }
}

#pragma mark - UITableViewDataSource

- (UITableViewCell*)tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    DPFileListTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:DPFileListTableViewCellIdentifier];
    cell.fileWrapper = _fileWrappers[_fileURLs[indexPath.row]];
    cell.editing = self.editing;
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return _fileURLs.count;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath
{
    return (self.parentFileURL != nil);
}

- (void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self showDeleteAlertWithIndexPath:indexPath];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.editing) {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"Choose Action" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction* action){
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDestructive handler:^(UIAlertAction* action){
            [self showDeleteAlertWithIndexPath:indexPath];
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction* action){
            [self showRenameAlertWithIndexPath:indexPath];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else {
        NSURL* fileURL = _fileURLs[indexPath.row];
        NSFileWrapper* fw = _fileWrappers[fileURL];
        if (fw.isDirectory) {
            NSError* error;
            NSArray* fileURLs = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:fileURL includingPropertiesForKeys:nil options:0 error:&error];
            if (error) {
                [self showErrorAlertWithError:error];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
            else {
                NSString* nibName = NSStringFromClass([self class]);
                NSBundle* bundle  = [NSBundle bundleForClass:[self class]];
                typeof(self) vc = [[[self class] alloc] initWithNibName:nibName bundle:bundle];
                vc.fileURLs = fileURLs;
                vc.parentFileURL = fileURL;
                vc.title = fw.filename;
                [self.navigationController pushViewController:vc animated:YES];
            }
        }
        else {
            UIDocumentInteractionController* documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            documentInteractionController.delegate = self;
            // BOOL success = [documentInteractionController presentOpenInMenuFromRect:self.view.frame inView:self.view animated:YES];
            BOOL success = [documentInteractionController presentOptionsMenuFromRect:self.view.frame inView:self.view animated:YES];
            if (success) {
                _documentInteractionController = documentInteractionController;
            }
            else {
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
}

#pragma mark - Alert Execute

- (void)pushedDeleteAlertButtonWithIndexPath:(NSIndexPath*)indexPath
{
    NSURL*   fileURL = _fileURLs[indexPath.row];
    NSError* error;
    [[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error];
    if (error) {
        [self showErrorAlertWithError:error];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        [_fileURLs removeObject:fileURL];
        [_fileWrappers removeObjectForKey:fileURL];
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

- (void)canceledDeleteAlertWithIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)pushedRenameAlertButtonWithIndexPath:(NSIndexPath*)indexPath newFileName:(NSString*)newFileName
{
    NSURL*    fileURL     = _fileURLs[indexPath.row];
    NSString* newFilePath = [[fileURL.path stringByDeletingLastPathComponent] stringByAppendingPathComponent:newFileName];
    NSURL*    newFileURL  = [NSURL fileURLWithPath:newFilePath];
    NSError*  error;
    [[NSFileManager defaultManager] moveItemAtURL:fileURL toURL:newFileURL error:&error];
    if (error) {
        [self showErrorAlertWithError:error];
        [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    else {
        NSFileWrapper* newFw = [[NSFileWrapper alloc] initWithURL:newFileURL options:NSFileWrapperReadingWithoutMapping error:&error];
        if (error) {
            [self showErrorAlertWithError:error];
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
        if (newFw) {
            [_fileURLs replaceObjectAtIndex:indexPath.row withObject:newFileURL];
            [_fileWrappers removeObjectForKey:fileURL];
            [_fileWrappers setObject:newFw forKey:newFileURL];
            DPFileListTableViewCell* cell = (DPFileListTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            cell.fileWrapper = newFw;
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)canceledRenameAlertWithIndexPath:(NSIndexPath*)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)pushedMkdirAlertButtonWithNewDirectoryName:(NSString*)newDirectoryName
{
    NSString*    newDirectoryPath = [self.parentFileURL.path stringByAppendingPathComponent:newDirectoryName];
    NSURL*       newDirectoryURL  = [NSURL fileURLWithPath:newDirectoryPath];
    NSError*     error;
    [[NSFileManager defaultManager] createDirectoryAtURL:newDirectoryURL withIntermediateDirectories:NO attributes:nil error:&error];
    if (error) {
        [self showErrorAlertWithError:error];
    }
    else {
        NSFileWrapper* newFw = [[NSFileWrapper alloc] initWithURL:newDirectoryURL options:NSFileWrapperReadingWithoutMapping error:&error];
        if (error) {
            [self showErrorAlertWithError:error];
        }
        if (newFw) {
            NSIndexPath* indexPath = [NSIndexPath indexPathForRow:_fileURLs.count inSection:0];
            [_fileURLs addObject:newDirectoryURL];
            [_fileWrappers setObject:newFw forKey:newDirectoryURL];
            [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
    }
}

#pragma mark - UIDocumentInteractionControllerDelegate

/*
- (void)documentInteractionControllerWillPresentOptionsMenu:(UIDocumentInteractionController*)controller
{
    
}
 */

- (void)documentInteractionControllerDidDismissOptionsMenu:(UIDocumentInteractionController*)controller
{
    if (controller == _documentInteractionController) {
        for (NSIndexPath* indexPath in self.tableView.indexPathsForSelectedRows) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

/*
- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController*)controller
{
    
}
 */

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController*)controller
{
    if (controller == _documentInteractionController) {
        for (NSIndexPath* indexPath in self.tableView.indexPathsForSelectedRows) {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
    }
}

- (void)documentInteractionController:(UIDocumentInteractionController*)controller willBeginSendingToApplication:(NSString*)application // bundle ID
{
    if (controller == _documentInteractionController) {
        NSLog(@"%@, application -> %@", NSStringFromSelector(_cmd), application);
    }
}

- (void)documentInteractionController:(UIDocumentInteractionController*)controller didEndSendingToApplication:(NSString*)application
{
    if (controller == _documentInteractionController) {
        _documentInteractionController = nil;
    }
}

#pragma mark - RootFileList

+ (NSArray<NSURL*>*)rootFileURLs
{
    /*
    NSSearchPathDirectory directories[] = {
        NSApplicationDirectory,
        NSDemoApplicationDirectory,
        NSDeveloperApplicationDirectory,
        NSAdminApplicationDirectory,
        NSLibraryDirectory,
        NSDeveloperDirectory,
        NSUserDirectory,
        NSDocumentationDirectory,
        NSDocumentDirectory,
        NSCoreServiceDirectory,
        NSAutosavedInformationDirectory,
        NSDesktopDirectory,
        NSCachesDirectory,
        NSApplicationSupportDirectory,
        NSDownloadsDirectory,
        NSInputMethodsDirectory,
        NSMoviesDirectory,
        NSMusicDirectory,
        NSPicturesDirectory,
        NSPrinterDescriptionDirectory,
        NSSharedPublicDirectory,
        NSPreferencePanesDirectory,
        NSItemReplacementDirectory,
        NSAllApplicationsDirectory,
        NSAllLibrariesDirectory
    };
    uint16_t directoriesCount = 25;
     */
    
    NSMutableArray<NSURL*>* fileURLs = [NSMutableArray<NSURL*> array];
    {
        NSSearchPathDirectory directories[] = {
            NSLibraryDirectory,
            NSDocumentDirectory,
            NSCachesDirectory,
        };
        uint16_t directoriesCount = 3;
        for (int i = 0; i < directoriesCount; i++) {
            for (NSString* path in NSSearchPathForDirectoriesInDomains(directories[i], NSUserDomainMask, YES)) {
                NSURL* fileURL = [NSURL fileURLWithPath:path];
                if (fileURL && [fileURLs containsObject:fileURL] == NO) {
                    [fileURLs addObject:fileURL];
                }
            }
        }
    }
    return fileURLs.copy;
}

+ (instancetype)rootFileListViewController
{
    NSString* nibName = NSStringFromClass([self class]);
    NSBundle* bundle  = [NSBundle bundleForClass:[self class]];
    DPFileListViewController* rootFileListViewController = [[self alloc] initWithNibName:nibName bundle:bundle];
    rootFileListViewController.fileURLs = [self rootFileURLs];
    rootFileListViewController.title = @"Root";
    return rootFileListViewController;
}

@end
