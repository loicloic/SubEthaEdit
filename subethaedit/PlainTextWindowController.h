//
//  PlainTextWindowController.h
//  SubEthaEdit
//
//  Created by Dominik Wagner on Fri Mar 05 2004.
//  Copyright (c) 2004 TheCodingMonkeys. All rights reserved.
//

#import <AppKit/AppKit.h>


@class ParticipantsView,PlainTextEditor;
extern NSString * const PlainTextWindowToolbarIdentifier;
extern NSString * const ParticipantsToolbarItemIdentifier;
extern NSString * const ShiftLeftToolbarItemIdentifier;
extern NSString * const ShiftRightToolbarItemIdentifier;
extern NSString * const RendezvousToolbarItemIdentifier;
extern NSString * const ToggleChangeMarksToolbarItemIdentifier;
extern NSString * const ToggleAnnouncementToolbarItemIdentifier;

@interface PlainTextWindowController : NSWindowController {

    // praticipants
    IBOutlet NSDrawer         *O_participantsDrawer;
    IBOutlet NSScrollView     *O_participantsScrollView;
    IBOutlet NSSplitView      *O_participantsSplitView;
    IBOutlet NSView           *O_newUserView;
    IBOutlet ParticipantsView *O_participantsView;
    IBOutlet NSPopUpButton    *O_actionPullDown;
    IBOutlet NSPopUpButton    *O_pendingUsersAccessPopUpButton;
    IBOutlet NSButton         *O_kickButton;
    IBOutlet NSButton         *O_readOnlyButton;
    IBOutlet NSButton         *O_readWriteButton;
    NSMutableArray *I_plainTextEditors;
}

- (IBAction)changePendingUsersAccess:(id)aSender;
- (NSArray *)plainTextEditors;
- (PlainTextEditor *)activePlainTextEditor;

- (IBAction)openParticipantsDrawer:(id)aSender;
- (IBAction)closeParticipantsDrawer:(id)aSender;

- (void)validateButtons;

- (IBAction)kickButtonAction:(id)aSender;
- (IBAction)readOnlyButtonAction:(id)aSender;
- (IBAction)readWriteButtonAction:(id)aSender;

- (void)gotoLine:(unsigned)aLine;
- (void)selectRange:(NSRange)aRange;

- (void)setSizeByColumns:(int)aColumns rows:(int)aRows;

- (BOOL)showsGutter;
- (void)setShowsGutter:(BOOL)aFlag;
- (IBAction)toggleLineNumbers:(id)aSender;

@end
