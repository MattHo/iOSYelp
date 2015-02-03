//
//  BusinessViewController.m
//  Yelp
//
//  Created by Matt Ho on 2/3/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "UIImageView+AFNetworking.h"
#import "BusinessViewController.h"
#import "AddressCell.h"

@interface BusinessViewController () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *thumbView;
@property (weak, nonatomic) IBOutlet UIImageView *ratingView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *reviewLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *addressTableView;

@end

@implementation BusinessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self loadBusiness:self.business];
    [self loadMap];
    
    self.addressTableView.delegate = self;
    self.addressTableView.dataSource = self;
    [self.addressTableView registerNib:[UINib nibWithNibName:@"AddressCell" bundle:nil] forCellReuseIdentifier:@"AddressCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (void)loadBusiness:(Business *)business {
    _business = business;
    
    [self.ratingView setImageWithURL:[NSURL URLWithString:business.ratingImageUrl]];
    self.reviewLabel.text = [NSString stringWithFormat:@"%ld Reviews", business.numReviews];
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f mi", business.distance];
    self.nameLabel.text = business.name;
    self.categoryLabel.text = business.categories;
    [self.thumbView setImageWithURL:[NSURL URLWithString:business.imageUrl]];
    // self.addressLabel.text = self.business.address;
}

- (void)loadMap {
    if (self.business.location) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.business.location.coordinate, 3000, 3000);
        [self.mapView setRegion:region animated:NO];
        [self.mapView addAnnotation:self.business.location];
        self.mapView.hidden = NO;
    } else {
        self.mapView.hidden = YES;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AddressCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
    cell.addressLabel.text = self.business.fullAddress;
    cell.cityLabel.text = self.business.city;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [self.business.location.mapItem openInMapsWithLaunchOptions:launchOptions];
}

@end
