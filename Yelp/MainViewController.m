//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//
#import <MapKit/MapKit.h>
#import "MainViewController.h"
#import "FiltersViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, FiltersViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (nonatomic, strong) BusinessCell *prototypeCell;
@property (nonatomic, strong) NSMutableDictionary *filters;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) NSNumber *offset;

- (void)fetchBusinessWithQuery:(NSString *)query params:(NSDictionary *)params;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        [self fetchBusinessWithQuery:@"Restaurants" params:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    self.tableView.rowHeight = UITableViewAutomaticDimension;

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];

    UISearchBar *searchBar = [[UISearchBar alloc] init];
    searchBar.delegate = self;
    searchBar.placeholder = @"search restaurant";
    self.navigationItem.titleView = searchBar;
    self.searchBar = searchBar;
    
    UIView *tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)];
    UIActivityIndicatorView *loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingView startAnimating];
    loadingView.center = tableFooterView.center;
    [tableFooterView addSubview:loadingView];
    self.tableView.tableFooterView = tableFooterView;
    self.tableView.tableFooterView.hidden = YES;
    
    self.filters = [NSMutableDictionary dictionary];
    self.businesses = [NSMutableArray array];
    self.offset = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    cell.business = self.businesses[indexPath.row];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    if (indexPath.row == self.businesses.count - 1 && [self.offset integerValue] < self.businesses.count &&
        [self.offset integerValue] < 100) {
        self.tableView.tableFooterView.hidden = NO;
        self.offset = [NSNumber numberWithLong:self.businesses.count];
        [self.filters setValue:self.offset forKey:@"offset"];
        [self fetchBusinessWithQuery:self.searchBar.text params:self.filters];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.prototypeCell.business = self.businesses[indexPath.row];
    
    CGSize size = [self.prototypeCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    return size.height + 1;
}

#pragma mark - UISearchBarDelegate Methods

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar.viewForBaselineLayout endEditing:YES];
    [self fetchBusinessWithQuery:searchBar.text params:nil];
}

#pragma mark - Filter delegate methods

- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    [self.filters removeAllObjects];
    [self.filters setValuesForKeysWithDictionary:filters];
    [self fetchBusinessWithQuery:self.searchBar.text params:filters];
    [self.businesses removeAllObjects];
}

#pragma mark - Private methods
- (void)fetchBusinessWithQuery:(NSString *)query params:(NSDictionary *)params {
    [self.client searchWithTerm:query params:params success:^(AFHTTPRequestOperation *operation, id response) {
        NSArray *businessDictionaries = response[@"businesses"];
        
        self.tableView.tableFooterView.hidden = YES;
        [self.businesses addObjectsFromArray:[Business businessWithDictionaries:businessDictionaries]];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

- (void)onListButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Map" style:UIBarButtonItemStylePlain target:self action:@selector(onMapButton)];
    
    self.tableView.hidden = NO;
    [UIView transitionWithView:self.mapView duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [UIView transitionWithView:self.tableView duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            self.mapView.hidden = YES;
        } completion:nil];
    } completion:nil];
}

- (void)onMapButton {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"List" style:UIBarButtonItemStylePlain target:self action:@selector(onListButton)];

    CLLocationCoordinate2D userLocation;
    userLocation.latitude = 37.774866;
    userLocation.longitude = -122.394556;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation, 3000, 3000);
    [self.mapView setRegion:region animated:NO];
    self.mapView.hidden = NO;

    [UIView transitionWithView:self.tableView duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
        [UIView transitionWithView:self.mapView duration:1.0f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            self.tableView.hidden = YES;
        } completion:^(BOOL finished) {
            for (Business *business in self.businesses) {
                if (business.location) {
                    [self.mapView addAnnotation:business.location];
                }
            }
        }];
    } completion:nil];
}

- (BusinessCell *) prototypeCell {
    if (!_prototypeCell) {
        _prototypeCell = [self.tableView dequeueReusableCellWithIdentifier:@"BusinessCell"];
    }
    return _prototypeCell;
}

@end
