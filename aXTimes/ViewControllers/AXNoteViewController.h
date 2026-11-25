//
//  AXNoteViewController.h
//  aXTimes
//
//  Created by fuesec on 5/20/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//


@protocol AXNoteViewControllerProtocol <NSObject>

- (void)doneChangingComment:(NSString *)comment;

@end

@interface AXNoteViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *textToDisplay;
@property (weak, nonatomic) id<AXNoteViewControllerProtocol> delegate;

@end
