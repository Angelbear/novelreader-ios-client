//
//  CategoryResultViewController.h
//  xiaoshuoyuedu
//
//  Created by Yangyang Zhao on 13-6-27.
//  Copyright (c) 2013年 Yangyang Zhao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RankViewController.h"

@interface CategoryResultViewController : RankViewController

@property(nonatomic, assign) NSUInteger type;
@property(nonatomic, strong) NSString* fromSource;
@property(nonatomic, strong) NSString* name;
- (id) initWithType:(NSUInteger)type source:(NSString*) from name:(NSString*)name;
@end
