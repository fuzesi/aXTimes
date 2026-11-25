//
//  AXDefaultCommentViewController.h
//  aXTimes
//
//  Created by fuesec on 6/11/13.
//  Copyright (c) 2013 aXimilate. All rights reserved.
//

@protocol AXDefaultCommentViewControllerDelegate<NSObject>

- (void)setStringFromTextView:(NSString *)text;

@end

@interface AXDefaultCommentViewController : UIViewController<UITextViewDelegate>
@property (strong, nonatomic) id<AXDefaultCommentViewControllerDelegate> delegate;
@property (strong, nonatomic) NSString *initialString;
@property (strong, nonatomic) NSString *controllerTitle;
@end
