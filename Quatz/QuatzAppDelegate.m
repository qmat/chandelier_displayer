//
//  QuatzAppDelegate.m
//  Quatz
//
//  Created by Vincent Akkermans on 10/01/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "QuatzAppDelegate.h"

@implementation QuatzAppDelegate

@synthesize window;
@synthesize mainView;
@synthesize mainFrame;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    currentViews = [[NSMutableArray alloc] init];
    mainView = [window contentView];
    
    #ifdef FULL_SCREEN
    NSDictionary *opts = [NSDictionary dictionaryWithObjectsAndKeys:
                          [NSNumber numberWithBool:YES], NSFullScreenModeAllScreens,
                          nil];
    [mainView enterFullScreenMode:[NSScreen mainScreen] 
                      withOptions:opts];
    #endif
    
    mainFrame = [mainView.window frame];
    
    #ifdef DUAL_SCREEN
    mainFrame.size.width *= 2;
    #endif 
    
    [mainView.window setContentSize:mainFrame.size];

    
    
    [NSThread detachNewThreadSelector:@selector(startZeroMQThread)
                             toTarget:self 
                           withObject:nil];
}

- (void)releaseCurrentViews
{
    // release all the currentViews
    while([currentViews count] > 0)
    {
        [[currentViews objectAtIndex:0] removeFromSuperview];
        [[currentViews objectAtIndex:0] release];
        [currentViews removeObjectAtIndex:0];
    }
}

- (void)startWebView:(NSDictionary*)arguments
{
    [self releaseCurrentViews];
    // add new views
    NSArray *urls = [arguments objectForKey:@"urls"];
    int views = [[arguments objectForKey:@"views"] intValue]; // number of new views
    int viewWidth = mainFrame.size.width / views;             // the width of each new view
    for(int i=0; i<views; i++)
    {
        // set the position, width, and height for the viwes
        WebView *view = [[WebView alloc] initWithFrame:NSMakeRect(0, 0, viewWidth, mainFrame.size.height)];
        [view setFrameOrigin:NSMakePoint(i*viewWidth,0)];
        // cycle through the available urls, this way you can for example have 8 views with 1 url, or 4 views with 2 urls repeated twice.
        [view setMainFrameURL:[urls objectAtIndex:(i%[urls count])]];
        [currentViews addObject:view];
        [mainView addSubview:view];
    }
    [mainView setNeedsDisplay:YES];
}

- (void)startQuartzView:(NSDictionary *)arguments
{
    [self releaseCurrentViews];
    QCView *view = [[QCView alloc] initWithFrame:NSMakeRect(0, 0, mainFrame.size.width, mainFrame.size.height)];
    [currentViews addObject:view];
    [mainView addSubview:view];
    [view loadCompositionFromFile:[arguments objectForKey:@"file"]];
    [view startRendering];
}

- (void)startZeroMQThread
{
    ZMQContext *context = [[ZMQContext alloc] initWithIOThreads:1];
    ZMQSocket *socket = [context socketWithType:4];
    
    [socket bindToEndpoint:ZMQ_ADDRESS];
    
    zmq_pollitem_t pollItems[1];
    [socket getPollItem:pollItems forEvents:ZMQ_POLLIN];
    
    [NSThread sleepForTimeInterval:1];
    
    NSString* OK= @"";
    
    while(true)
    {
        int rs = [ZMQContext pollWithItems:pollItems 
                                     count:1 
                          timeoutAfterUsec:ZMQPollTimeoutNever];
        // sanity check whether we have actually received anything
        if(rs > 0 && pollItems[0].revents == ZMQ_POLLIN)
        {
            // get the data from the socket
            NSData *data = [socket receiveDataWithFlags:0];
            // interpret the data, should be json
            NSDictionary *dict = [data yajl_JSON];
            // output the dictionary, pretty-printed
            //NSLog(@"%@", [dict yajl_JSONStringWithOptions:YAJLGenOptionsBeautify indentString:@"    "]);
            // what should we do?
            NSString *mode = [dict objectForKey:@"mode"];
            if([mode isEqualToString:@"web"])
            {
                [self performSelectorOnMainThread:@selector(startWebView:)
                                       withObject:[dict objectForKey:@"arguments"]
                                    waitUntilDone:false];
            }
            if([mode isEqualToString:@"quartz"])
            {
                [self performSelectorOnMainThread:@selector(startQuartzView:)
                                       withObject:[dict objectForKey:@"arguments"]
                                    waitUntilDone:false];
            }
            
            // send something  back so that the REQ socket is valid again
            [socket sendData:[OK dataUsingEncoding:NSUTF8StringEncoding]
                   withFlags:0];
            
        }
        
    }
    
}

/**
    Returns the directory the application uses to store the Core Data store file. This code uses a directory named "Quatz" in the user's Library directory.
 */
- (NSURL *)applicationFilesDirectory {

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *libraryURL = [[fileManager URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject];
    return [libraryURL URLByAppendingPathComponent:@"Quatz"];
}

/**
    Creates if necessary and returns the managed object model for the application.
 */
- (NSManagedObjectModel *)managedObjectModel {
    if (__managedObjectModel) {
        return __managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Quatz" withExtension:@"momd"];
    __managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return __managedObjectModel;
}

/**
    Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    if (__persistentStoreCoordinator) {
        return __persistentStoreCoordinator;
    }

    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:[NSArray arrayWithObject:NSURLIsDirectoryKey] error:&error];
        
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    else {
        if ([[properties objectForKey:NSURLIsDirectoryKey] boolValue] != YES) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]]; 
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"Quatz.storedata"];
    __persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![__persistentStoreCoordinator addPersistentStoreWithType:NSXMLStoreType configuration:nil URL:url options:nil error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        [__persistentStoreCoordinator release], __persistentStoreCoordinator = nil;
        return nil;
    }

    return __persistentStoreCoordinator;
}

/**
    Returns the managed object context for the application (which is already
    bound to the persistent store coordinator for the application.) 
 */
- (NSManagedObjectContext *)managedObjectContext {
    if (__managedObjectContext) {
        return __managedObjectContext;
    }

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    __managedObjectContext = [[NSManagedObjectContext alloc] init];
    [__managedObjectContext setPersistentStoreCoordinator:coordinator];

    return __managedObjectContext;
}

/**
    Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
 */
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window {
    return [[self managedObjectContext] undoManager];
}

/**
    Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
 */
- (IBAction)saveAction:(id)sender {
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }

    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}

- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender {

    // Save changes in the application's managed object context before the application terminates.

    if (!__managedObjectContext) {
        return NSTerminateNow;
    }

    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }

    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }

    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        [alert release];
        alert = nil;
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

- (void)dealloc
{
    [__managedObjectContext release];
    [__persistentStoreCoordinator release];
    [__managedObjectModel release];
    [super dealloc];
}

@end
