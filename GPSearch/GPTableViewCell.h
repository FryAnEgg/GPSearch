//
//  GPTableViewCell.h
//  GPSearch
//
//  Created by David Lathrop on 4/29/15.
//  Copyright (c) 2015 Fry An Egg Technology. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GPTableViewCell : UITableViewCell

@property (nonatomic,strong) IBOutlet UILabel *titleLabel;
@property (nonatomic,strong) IBOutlet UILabel *typesLabel;
@property (nonatomic,strong) IBOutlet UIImageView *gpImageView;
@property (nonatomic,strong) IBOutlet UILabel *openLabel;

@end
