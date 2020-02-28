//
//  ccCollectionViewCell.m
//  openGL-加载图片
//
//  Created by mac on 2020/2/25.
//  Copyright © 2020 cc. All rights reserved.
//

#import "ccCollectionViewCell.h"

@implementation ccCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor blueColor];
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        self.label.adjustsFontSizeToFitWidth = YES;
        [self addSubview:self.label];
    }
    return self;
}


@end
