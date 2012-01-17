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
#define ZMQ_ADDRESS @"tcp://127.0.0.1:10000"
#define TOTAL_WIDTH 6400
#define TOTAL_HEIGHT 600

@interface QuatzAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    NSMutableArray *currentViews;
    NSView *mainView;
    NSRect mainFrame;

    NSPersistentStoreCoordinator *__persistentStoreCoordinator;
    NSManagedObjectModel *__managedObjectModel;
    NSManagedObjectContext *__managedObjectContext;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet NSView *mainView;
@property (assign) IBOutlet NSRect mainFrame;

@property (nonatomic, retain, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, retain, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

- (void)startZeroMQThread;
- (void)releaseCurrentViews;
- (void)startWebView:(NSDictionary*)arguments;      // for starting websites or processing sketches
- (void)startQuartzView:(NSDictionary*)arguments;   // for starting quartz sketches


@end
