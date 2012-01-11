//
//  QuatzAppDelegate.h
//  Quatz
//
//  Created by Vincent Akkermans on 10/01/2012.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>
#import <WebKit/WebKit.h>

#define DUAL_SCREEN

@interface QuatzAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    WebView *webView;

    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webView;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
