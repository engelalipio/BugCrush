//
//  AMSSwap.m
//  ECrush
//
//  Created by Engel Alipio on 8/16/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSSwap.h"
#import "AMSInsect.h"

@implementation AMSSwap

@synthesize originalInsect = _originalInsect;
@synthesize destinationInsect = _destinationInsect;


- (NSString *)description {
    return [NSString stringWithFormat:@"%@ swap %@ with %@", [super description], self.originalInsect, self.destinationInsect];
}

- (BOOL)isEqual:(id)object {
    // You can only compare this object against other RWTSwap objects.
    if (![object isKindOfClass:[AMSSwap class]]) return NO;
    
    // Two swaps are equal if they contain the same cookie, but it doesn't
    // matter whether they're called A in one and B in the other.
    AMSSwap *other = (AMSSwap *)object;
    return (other.originalInsect == self.originalInsect && other.destinationInsect == self.destinationInsect) ||
    (other.destinationInsect == self.originalInsect && other.originalInsect == self.destinationInsect);
}

- (NSUInteger)hash {
    return [self.originalInsect hash] ^ [self.destinationInsect hash];
}

@end
