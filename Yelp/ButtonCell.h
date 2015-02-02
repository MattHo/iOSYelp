//
//  ButtonCell.h
//  Yelp
//
//  Created by Matt Ho on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ButtonCell;

@protocol ButtonCellDelegate <NSObject>

- (void)buttonCell:(ButtonCell *)cell didUpdateValue:(BOOL)value;

@end

@interface ButtonCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak) id<ButtonCellDelegate> delegate;

- (void)setOn:(BOOL)on animated:(BOOL)animated;

@end
