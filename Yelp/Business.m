//
//  Business.m
//  Yelp
//
//  Created by Matt Ho on 1/31/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"

@implementation Business

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    if (self) {
        NSArray *categories = dictionary[@"categories"];
        NSMutableArray *categoryNames = [NSMutableArray array];
        [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [categoryNames addObject:obj[0]];
        }];
        self.categories = [categoryNames componentsJoinedByString:@", "];
        
        self.name = dictionary[@"name"];
        self.imageUrl = dictionary[@"image_url"];

        NSMutableArray *street = [NSMutableArray array];
        NSArray *address = [dictionary valueForKeyPath:@"location.address"];
        if (address.count > 0) {
            [street addObject:address[0]];
        }

        NSArray *neighborhood = [dictionary valueForKeyPath:@"location.neighborhoods"];
        if (neighborhood.count > 0) {
            [street addObject:neighborhood[0]];
        }

        self.address = [street componentsJoinedByString:@", "];
        
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageUrl = dictionary[@"rating_img_url"];
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
    }
    
    return self;
}

+ (NSArray *)businessWithDictionaries:(NSArray *)dictionaries {
    NSMutableArray *businesses = [NSMutableArray array];
    
    for (NSDictionary *dictionary in dictionaries) {
        Business *business = [[Business alloc] initWithDictionary:dictionary];
        [businesses addObject:business];
    }
    
    return businesses;
}

@end
