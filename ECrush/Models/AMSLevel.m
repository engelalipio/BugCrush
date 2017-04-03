//
//  AMSLevel.m
//  ECrush
//
//  Created by Engel Alipio on 8/15/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#import "AMSLevel.h"
#import "AMSSwap.h"

@implementation AMSLevel{
    AMSInsect *_insects[NumColumns][NumRows];
    AMSTile *_tiles[NumColumns][NumRows];
}
@synthesize targetScore = _targetScore;
@synthesize maximumMoves = _maximumMoves;
@synthesize comboMultiplier = _comboMultiplier;
@synthesize levelName = _levelName;

- (void)performSwap:(AMSSwap *)swap {
    
    NSInteger columnA = swap.originalInsect.column;
    NSInteger rowA = swap.originalInsect.row;
    NSInteger columnB = swap.destinationInsect.column;
    NSInteger rowB = swap.destinationInsect.row;
    
    _insects[columnA][rowA] = swap.destinationInsect;
    swap.destinationInsect.column = columnA;
    swap.destinationInsect.row = rowA;
    
    _insects[columnB][rowB] = swap.originalInsect;
    swap.originalInsect.column = columnB;
    swap.originalInsect.row = rowB;
    
}

- (void)resetComboMultiplier {
    self.comboMultiplier = 1;
}

- (void)calculateScores:(NSSet *)chains {
    
    for (AMSChain *chain in chains) {
        chain.score = 60 * ([chain.insects count] - 2) * self.comboMultiplier;
        self.comboMultiplier++;
    }
}

- (NSArray *)fillHoles {
    NSMutableArray *columns = [NSMutableArray array];
    
    // 1
    for (NSInteger column = 0; column < NumColumns; column++) {
        
        NSMutableArray *array;
        for (NSInteger row = 0; row < NumRows; row++) {
            
            // 2
            if (_tiles[column][row] != nil && _insects[column][row] == nil) {
                
                // 3
                for (NSInteger lookup = row + 1; lookup < NumRows; lookup++) {
                    AMSInsect *insect = _insects[column][lookup];
                    if (insect != nil) {
                        // 4
                        _insects[column][lookup] = nil;
                        _insects[column][row] = insect;
                        insect.row = row;
                        
                        // 5
                        if (array == nil) {
                            array = [NSMutableArray array];
                            [columns addObject:array];
                        }
                        [array addObject:insect];
                        
                        // 6
                        break;
                    }
                }
            }
        }
    }
    return columns;
}

- (NSArray *)topUpInsects {
    NSMutableArray *columns = [NSMutableArray array];
    
    NSUInteger insectType = 0;
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        
        NSMutableArray *array;
        
        // 1
        for (NSInteger row = NumRows - 1; row >= 0 && _insects[column][row] == nil; row--) {
            
            // 2
            if (_tiles[column][row] != nil) {
                
                // 3
                NSUInteger newinsectType;
                do {
                    newinsectType = arc4random_uniform(insectTypesNumber) + 1;
                } while (newinsectType == insectType);
                insectType = newinsectType;
                
                // 4
                AMSInsect *insect = [self createInsectAtColumn:column row:row withType:insectType];
                
                // 5
                if (array == nil) {
                    array = [NSMutableArray array];
                    [columns addObject:array];
                }
                [array addObject:insect];
            }
        }
    }
    return columns;
}



- (NSSet *)removeMatches {
    NSSet *horizontalChains = [self detectHorizontalMatches];
    NSSet *verticalChains = [self detectVerticalMatches];
    
    [self removeInsects:horizontalChains];
    [self removeInsects:verticalChains];
    
    [self calculateScores:horizontalChains];
    [self calculateScores:verticalChains];
    
    return [horizontalChains setByAddingObjectsFromSet:verticalChains];
}

- (void)removeInsects:(NSSet *)chains {
    for (AMSChain *chain in chains) {
        for (AMSInsect *insect in chain.insects) {
            _insects[insect.column][insect.row] = nil;
        }
    }
}

- (NSSet *)detectVerticalMatches {
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger column = 0; column < NumColumns; column++) {
        for (NSInteger row = 0; row < NumRows - 2; ) {
            if (_insects[column][row] != nil) {
                NSUInteger matchType = _insects[column][row].insectType;
                
                if (_insects[column][row + 1].insectType == matchType
                    && _insects[column][row + 2].insectType == matchType) {
                    
                    AMSChain *chain = [[AMSChain alloc] init];
                    chain.chainType = ChainTypeVertical;
                    do {
                        [chain addInsect:_insects[column][row]];
                        row += 1;
                    }
                    while (row < NumRows && _insects[column][row].insectType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }
            }
            row += 1;
        }
    }
    return set;
}

- (NSSet *)detectHorizontalMatches {
    // 1
    NSMutableSet *set = [NSMutableSet set];
    
    // 2
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns - 2; ) {
            
            // 3
            if (_insects[column][row] != nil) {
                NSUInteger matchType = _insects[column][row].insectType;
                
                // 4
                if (_insects[column + 1][row].insectType == matchType
                    && _insects[column + 2][row].insectType == matchType) {
                    // 5
                    AMSChain *chain = [[AMSChain alloc] init];
                    chain.chainType = ChainTypeHorizontal;
                    do {
                        [chain addInsect:_insects[column][row]];
                        column += 1;
                    }
                    while (column < NumColumns && _insects[column][row].insectType == matchType);
                    
                    [set addObject:chain];
                    continue;
                }
            }
            
            // 6
            column += 1;
        }
    }
    return set;
}

- (NSDictionary *)loadJSON:(NSString *)filename {
    
    NSDictionary *dictionary = nil;
    
    NSData *data = nil;
    
    NSString *message = @"",
             *path    = @"";
    
    NSError *error = nil;
    
    @try {
        
        path = [[NSBundle mainBundle] pathForResource:filename ofType:@"json"];
        if (path == nil) {
            message = [NSString stringWithFormat:@"Could not find level file: %@", filename];
            return dictionary;
        }
        
        
        data = [NSData dataWithContentsOfFile:path options:0 error:&error];
        
        if (data == nil) {
            message = [NSString stringWithFormat:@"Could not load level file: %@, error: %@", filename, error];
            return dictionary;
        }
        
        dictionary = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (dictionary == nil || ![dictionary isKindOfClass:[NSDictionary class]]) {
            message = [NSString stringWithFormat:@"Level file '%@' is not valid JSON: %@", filename, error];;
            return dictionary;
        }

    }
    @catch (NSException *exception) {
        message = [NSString stringWithFormat:@"loadJSON:Exception->%@", [exception description]];
    }
    @finally {
        NSLog(@"%@",message);
        message = @"";
    }
    
    
    return dictionary;
}

- (instancetype)initWithFile:(NSString *)filename{
    
    self = [super init];
    if (self != nil) {
        NSDictionary *dictionary = [self loadJSON:filename];
        
        //Extracting the target and total moves out of the map
        self.targetScore = [dictionary[@"targetScore"] unsignedIntegerValue];
        self.maximumMoves = [dictionary[@"moves"] unsignedIntegerValue];
        self.levelName = [dictionary objectForKey:@"title"];
        // Loop through the rows
        [dictionary[@"tiles"] enumerateObjectsUsingBlock:^(NSArray *array, NSUInteger row, BOOL *stop) {
            
            // Loop through the columns in the current row
            [array enumerateObjectsUsingBlock:^(NSNumber *value, NSUInteger column, BOOL *stop) {
                
                // Note: In Sprite Kit (0,0) is at the bottom of the screen,
                // so we need to read this file upside down.
                NSInteger tileRow = NumRows - row - 1;
                
                // If the value is 1, create a tile object.
                if ([value integerValue] == 1) {
                    _tiles[column][tileRow] = [[AMSTile alloc] init];
                }
            }];
        }];
    }
    return self;
}

- (AMSTile *)tileAtColumn:(NSInteger)column row:(NSInteger)row{
    AMSTile *tile = nil;
    NSString *message = @"";
    @try {
        
        tile = _tiles[column][row];
        
    }
    @catch (NSException *exception) {
        message = [NSString stringWithFormat:@"tileAtColumn:error->%@",[exception description]];
        NSLog(@"%@",message);
    }
    @finally {
        message = @"";
    }
    return tile;
}

- (BOOL)hasChainAtColumn:(NSInteger)column row:(NSInteger)row {
    
    BOOL hasChain = NO;
    
    NSUInteger insectType = -1,
               horzLength = -1,
               vertLength = -1;
    
    NSString *message = @"";
    
    @try {
        
         insectType = _insects[column][row].insectType;
        
         horzLength = 1;
         vertLength = 1;
        
        for (NSInteger i = column - 1; i >= 0 && _insects[i][row].insectType == insectType; i--, horzLength++) ;
        
        for (NSInteger i = column + 1; i < NumColumns && _insects[i][row].insectType == insectType; i++, horzLength++) ;
        
        hasChain = (horzLength >= 3);
        message = [NSString stringWithFormat:@"hasChainAtColumn:Horizontal->%hhd",hasChain];
        if (hasChain) {
            //NSLog(@"%@",message);
            return hasChain;
        }else{
        
            for (NSInteger i = row - 1; i >= 0 && _insects[column][i].insectType == insectType; i--, vertLength++) ;
        
            for (NSInteger i = row + 1; i < NumRows && _insects[column][i].insectType == insectType; i++, vertLength++) ;
        
            hasChain =  (vertLength >= 3);
            message = [NSString stringWithFormat:@"hasChainAtColumn:Vertical->%hhd",hasChain];
            if (hasChain){
              //  NSLog(@"%@",message);
            }
        }
        
    }
    @catch (NSException *exception) {
        message = [NSString stringWithFormat:@"hasChainAtColumn:error->%@",[exception description]];
        NSLog(@"%@",message);
    }
    @finally {
        insectType = -1,
        horzLength = -1,
        vertLength = -1;
        message = @"";
    }
    return hasChain;


}

- (void)detectPossibleSwaps {
    NSMutableSet *set = [NSMutableSet set];
    
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            AMSInsect *insect = _insects[column][row];
            if (insect != nil) {
                
                // Is it possible to swap this insect with the one on the right?
                if (column < NumColumns - 1) {
                    // Have a insect in this spot? If there is no tile, there is no insect.
                    AMSInsect *other = _insects[column + 1][row];
                    if (other != nil) {
                        // Swap them
                        _insects[column][row] = other;
                        _insects[column + 1][row] = insect;
                        
                        // Is either insect now part of a chain?
                        if ([self hasChainAtColumn:column + 1 row:row] || [self hasChainAtColumn:column row:row]) {
                            
                            AMSSwap *swap = [[AMSSwap alloc] init];
                            swap.originalInsect = insect;
                            swap.destinationInsect = other;
                            [set addObject:swap];
                        }
                        
                        // Swap them back
                        _insects[column][row] = insect;
                        _insects[column + 1][row] = other;
                    }
                }
                
                if (row < NumRows - 1) {
                    
                    AMSInsect *other = _insects[column][row + 1];
                    if (other != nil) {
                        // Swap them
                        _insects[column][row] = other;
                        _insects[column][row + 1] = insect;
                        
                        if ([self hasChainAtColumn:column row:row + 1] ||  [self hasChainAtColumn:column row:row]) {
                            
                            AMSSwap *swap = [[AMSSwap alloc] init];
                            swap.originalInsect = insect;
                            swap.destinationInsect = other;
                            [set addObject:swap];
                        }
                        
                        _insects[column][row] = insect;
                        _insects[column][row + 1] = other;
                    }
                }
            }
        }
    }
    
    self.possibleSwaps = set;
}

- (BOOL)isPossibleSwap:(AMSSwap *)swap {
    return [self.possibleSwaps containsObject:swap];
}

-(NSSet *) shuffle{
    

    NSSet *insects = nil;
    NSString *message = @"";
    
    @try{
        do{
            
        insects = [self createInitialInsects];
        message = [NSString stringWithFormat:@"shuffle:message:Insects count->%lu", (unsigned long)[insects count]];
            
        [self detectPossibleSwaps];
        }
        while ([self.possibleSwaps count] == 0) ;
        
    }@catch(NSException *exception){
        message = [NSString stringWithFormat:@"shuffle:error->%@",[exception description]];
    }@finally{
       // NSLog(@"%@",message);
        message = @"";
    }
    return insects;
}

-(AMSInsect *) insectAtColumn:(NSInteger) column row:(NSInteger)row{
    AMSInsect *insect = nil;
    NSString *message = @"";
    @try {
        
        insect = _insects[column][row];
        
    }
    @catch (NSException *exception) {
        message = [exception description];
        NSLog(@"%@",message);
    }
    @finally {
        message = @"";
    }
    return insect;
}

- (NSSet *)createInitialInsects {
    NSMutableSet *set = [NSMutableSet set];
    
    // 1
    for (NSInteger row = 0; row < NumRows; row++) {
        for (NSInteger column = 0; column < NumColumns; column++) {
            
            if(_tiles[column][row] != nil){
            // 2
 
                
                NSUInteger cType;
                do {
                    cType = arc4random_uniform(insectTypesNumber) + 1;
                }
                while ((column >= 2 &&
                        _insects[column - 1][row].insectType == cType &&
                        _insects[column - 2][row].insectType == cType)
                       ||
                       (row >= 2 &&
                        _insects[column][row - 1].insectType == cType &&
                        _insects[column][row - 2].insectType == cType));
            
            // 3
            AMSInsect *insect = [self createInsectAtColumn:column row:row withType:cType];
            // 4
            [set addObject:insect];
            }
        }
    }
    return set;
}

- (AMSInsect *)createInsectAtColumn:(NSInteger)column row:(NSInteger)row withType:(NSUInteger)insectType {
    AMSInsect *insect = [[AMSInsect alloc] init];
    insect.insectType = insectType;
    insect.column = column;
    insect.row = row;
    _insects[column][row] = insect;
    return insect;
}
@end
