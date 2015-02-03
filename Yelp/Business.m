//
//  Business.m
//  Yelp
//
//  Created by Matt Ho on 1/31/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "Business.h"
#import "Location.h"

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
        self.numReviews = [dictionary[@"review_count"] integerValue];
        self.ratingImageUrl = dictionary[@"rating_img_url"];

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
        self.city = [dictionary valueForKeyPath:@"location.city"];
        
        NSArray *fullAddress = [dictionary valueForKeyPath:@"location.display_address"];
        if (fullAddress.count > 0) {
            self.fullAddress = [fullAddress componentsJoinedByString:@", "];
        }
        
        NSString *latitude = [dictionary valueForKeyPath:@"location.coordinate.latitude"];
        NSString *longitude = [dictionary valueForKeyPath:@"location.coordinate.longitude"];

        if (latitude != nil) {
            CLLocationCoordinate2D coordinate;
            coordinate.latitude = [latitude floatValue];
            coordinate.longitude = [longitude floatValue];
            
            self.location = [[Location alloc] initWithName:self.name address:self.address coordinate:coordinate];
        }
        
        float milesPerMeter = 0.000621371;
        self.distance = [dictionary[@"distance"] integerValue] * milesPerMeter;
        
        NSLog(@"%@", dictionary);
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
