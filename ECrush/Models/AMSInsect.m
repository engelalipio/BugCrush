//
//  AMSCookie.m
//  ECrush
//
//  Created by Engel Alipio on 8/15/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSInsect.h"


@implementation AMSInsect

@synthesize column = _column;
@synthesize row = _row;
@synthesize insectType = _insectType;
@synthesize insectSprite = _insectSprite;


- (NSString *)description {
    return [NSString stringWithFormat:@"type:%ld square:(%ld,%ld)", (long)self.insectType,
            (long)self.column, (long)self.row];
}

-(NSString*) spriteName{
    
    NSString *name    = @"",
             *message = @"";
    
    @try {
        
        static NSString * const spriteNames[] = {
            @"Scorpion",
            @"Beetle",
            @"Worm",
            @"Ant",
            @"Spider",
            @"Plant",
        };
        
        name = spriteNames[self.insectType - 1];
        
    }
    @catch (NSException *exception) {
        message = [NSString stringWithFormat:@"spriteName:error-[%@]", [exception description]];
        NSLog(@"%@",message);
    }
    @finally {
        message = @"";
    }
    return name;
    
}

-(NSString *) hightLightedSpriteName{
    NSString *name    = @"",
             *message = @"";
    
    @try {
        
        
        name = [NSString stringWithFormat:@"%@-Highlighted", [self spriteName]];
        
        
    }
    @catch (NSException *exception) {
        message = [NSString stringWithFormat:@"hightLightedSpriteName:error-[%@]", [exception description]];
        NSLog(@"%@",message);
    }
    @finally {
        message = @"";
    }
    return name;
}

@end
