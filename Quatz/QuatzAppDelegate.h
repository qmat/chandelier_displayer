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
#import "ZMQContext.h"
#import "ZMQSocket.h"
#import <YAJL/YAJL.h>

#define DUAL_SCREEN

@interface QuatzAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSView *currentView;
    NSView *mainView;
    NSRect mainFrame;

    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *currentView;
@property (assign) IBOutlet NSView *mainView;
@property (assign) IBOutlet NSRect mainFrame;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (void)startZeroMQThread;

// for starting websites or processing sketches
- (void)startWebView:(NSDictionary*)arguments;

// for starting quartz sketches
- (void)startQuartzView:(NSDictionary*)arguments;


@end
