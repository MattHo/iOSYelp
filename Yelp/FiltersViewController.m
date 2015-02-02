//
//  FiltersViewController.m
//  Yelp
//
//  Created by Matt Ho on 2/1/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "ButtonCell.h"
#import "SwitchCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, readonly) NSDictionary *filters;
@property (nonatomic, strong) NSMutableArray *sections;
@property (nonatomic, strong) NSArray *mainCategories;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, strong) NSString *showAllCategories;
@property (nonatomic, strong) NSString *hasDeal;
@property (nonatomic, strong) NSString *editSort;
@property (nonatomic, strong) NSString *editDistance;
@property (nonatomic, strong) NSString *sort;
@property (nonatomic, strong) NSString *distance;

- (void) initCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        self.hasDeal = @"NO";
        self.showAllCategories = @"NO";
        self.editSort = @"NO";
        self.editDistance = @"NO";
        self.sort = @"0";
        self.distance = @"0";
        [self initSections];
        [self initCategories];
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Filters";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Search" style:UIBarButtonItemStylePlain target:self action:@selector(onSearchButton)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;

    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ButtonCell" bundle:nil] forCellReuseIdentifier:@"ButtonCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.sections[section][@"name"];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ((section == 0 && [self.editSort isEqualToString:@"NO"]) ||
        (section == 1 && [self.editDistance isEqualToString:@"NO"]) || section == 2) {
        return 1;
    } else if (section == 3) {
        if ([self.showAllCategories isEqualToString:@"YES"]) {
            return self.categories.count + 1;
        } else {
            return self.mainCategories.count + 1;
        }
    } else {
        NSDictionary *sectionItem = [self.sections objectAtIndex:section];
        NSArray *items = [sectionItem objectForKey:@"items"];
        return items.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([self.editSort isEqualToString:@"YES"]) {
            NSDictionary *section = [self.sections objectAtIndex:indexPath.section];
            NSArray *items = [section objectForKey:@"items"];
            NSDictionary *item = [items objectAtIndex:indexPath.row];

            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            cell.titleLabel.text = item[@"name"];
            if ([item[@"code"] isEqualToString:self.sort]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            
            return cell;
        } else {
            NSDictionary *section = [self.sections objectAtIndex:indexPath.section];
            NSArray *items = [section objectForKey:@"items"];

            for (NSDictionary *item in items) {
                if ([item[@"code"] isEqualToString:self.sort]) {
                    ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
                    cell.titleLabel.text = item[@"name"];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    return cell;
                }
            }
            
            return nil;
        }
    } else if (indexPath.section == 1) {
        if ([self.editDistance isEqualToString:@"YES"]) {
            NSDictionary *section = [self.sections objectAtIndex:indexPath.section];
            NSArray *items = [section objectForKey:@"items"];
            NSDictionary *item = [items objectAtIndex:indexPath.row];

            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            cell.titleLabel.text = item[@"name"];
            if ([item[@"code"] isEqualToString:self.distance]) {
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
            }
            
            return cell;
        } else {
            NSDictionary *section = [self.sections objectAtIndex:indexPath.section];
            NSArray *items = [section objectForKey:@"items"];
            
            for (NSDictionary *item in items) {
                if ([item[@"code"] isEqualToString:self.distance]) {
                    ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
                    cell.titleLabel.text = item[@"name"];
                    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
                    return cell;
                }
            }
            
            return nil;
        }
    } else if (indexPath.section == 2) {
        return [self renderDealCell:tableView];
    } else {
        NSArray *items = [self.showAllCategories isEqualToString:@"YES"] ? self.categories : self.mainCategories;

        if (indexPath.row == items.count) {
            ButtonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ButtonCell"];
            cell.titleLabel.text = ([self.showAllCategories isEqualToString:@"YES"])? @"Show Less" : @"Show All";
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            return cell;
        } else {
            NSDictionary *item = [items objectAtIndex:indexPath.row];
            SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
            cell.titleLabel.text = item[@"name"];
            cell.on = [self.selectedCategories containsObject:items[indexPath.row]];
            cell.delegate = self;
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if ([self.editSort isEqualToString:@"NO"]) {
            self.editSort = @"YES";
        } else {
            self.editSort = @"NO";
            NSDictionary *section = [self.sections objectAtIndex:indexPath.section];
            NSArray *items = [section objectForKey:@"items"];
            NSDictionary *item = [items objectAtIndex:indexPath.row];
            self.sort = item[@"code"];
        }
        [self.tableView reloadData];
    } else if (indexPath.section == 1) {
        if ([self.editDistance isEqualToString:@"NO"]) {
            self.editDistance = @"YES";
        } else {
            self.editDistance = @"NO";
            NSDictionary *section = [self.sections objectAtIndex:indexPath.section];
            NSArray *items = [section objectForKey:@"items"];
            NSDictionary *item = [items objectAtIndex:indexPath.row];
            self.distance = item[@"code"];
        }
        [self.tableView reloadData];
    } else if (indexPath.section == 3) {
        NSArray *items = [self.showAllCategories isEqualToString:@"YES"] ? self.categories : self.mainCategories;
        
        if (indexPath.row == items.count) {
            self.showAllCategories = [self.showAllCategories isEqualToString:@"YES"] ? @"NO" : @"YES";
            [self.tableView reloadData];
        }
    }
}

#pragma mark - Switch cell delegate methods

- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    
    if (indexPath.section == 2) {
        self.hasDeal = value ? @"YES" : @"NO";
        [self.tableView reloadData];
    } else if (indexPath.section == 3) {
        NSArray *items = [self.showAllCategories isEqualToString:@"YES"] ? self.categories : self.mainCategories;
        
        if (value) {
            [self.selectedCategories addObject:items[indexPath.row]];
        } else {
            [self.selectedCategories removeObject:items[indexPath.row]];
        }
    }
}

#pragma mark - Private Methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    
    if ([self.hasDeal isEqualToString:@"YES"]) {
        [filters setObject:@"1" forKey:@"deal_filter"];
    }
    
    if (![self.distance isEqualToString:@"0"]) {
        [filters setObject:self.distance forKey:@"distance_filter"];
    }

    [filters setObject:self.sort forKey:@"sort"];
    return filters;
}

- (SwitchCell *)renderDealCell:(UITableView *)tableView {
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];

    if ([self.hasDeal isEqual: @"YES"]) {
        cell.titleLabel.text = @"On";
        cell.on = YES;
    } else {
        cell.titleLabel.text = @"Off";
        cell.on = NO;
    }

    cell.delegate = self;
    return cell;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onSearchButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initSections {
    self.sections = [NSMutableArray array];
    
    NSMutableDictionary *sort = [NSMutableDictionary dictionary];
    NSMutableArray *sortItems = [NSMutableArray array];
    [sortItems addObject:@{@"name":@"Best Match", @"code": @"0"}];
    [sortItems addObject:@{@"name":@"Distance", @"code": @"1"}];
    [sortItems addObject:@{@"name":@"Highest Rated", @"code": @"2"}];
    [sort setObject:@"Sort" forKey:@"name"];
    [sort setObject:sortItems forKey:@"items"];
    [self.sections addObject:sort];

    NSMutableDictionary *radius = [NSMutableDictionary dictionary];
    NSMutableArray *raduisItems = [NSMutableArray array];
    [raduisItems addObject:@{@"name":@"Best Match", @"code": @"0"}];
    [raduisItems addObject:@{@"name":@"0.5 km", @"code": @"500"}];
    [raduisItems addObject:@{@"name":@"2 km", @"code": @"2000"}];
    [raduisItems addObject:@{@"name":@"8 km", @"code": @"8000"}];
    [raduisItems addObject:@{@"name":@"15 km", @"code": @"15000"}];
    [radius setObject:@"Radius" forKey:@"name"];
    [radius setObject:raduisItems forKey:@"items"];
    [self.sections addObject:radius];

    NSMutableDictionary *deal = [NSMutableDictionary dictionary];
    NSMutableArray *dealItems = [NSMutableArray array];
    [dealItems addObject:@{@"name":@"ON", @"code": @YES}];
    [deal setObject:@"Deal" forKey:@"name"];
    [deal setObject:dealItems forKey:@"items"];
    [self.sections addObject:deal];
    
    NSMutableDictionary *categories = [NSMutableDictionary dictionary];
    [categories setObject:@"Category" forKey:@"name"];
    [self.sections addObject:categories];
}

- (void)initCategories {
    self.mainCategories =
    @[@{@"name":@"Japanese", @"code": @"japanese"},
      @{@"name":@"Taiwanese", @"code": @"taiwanese"},
      @{@"name":@"Thai", @"code": @"thai"}
    ];
    
    self.categories =
    @[@{@"name" : @"Barbeque", @"code": @"bbq" },
      @{@"name": @"Cafes", @"code": @"cafes"},
      @{@"name" : @"French", @"code": @"french" },
      @{@"name": @"Hot Pot", @"code": @"hotpot"},
      @{@"name" : @"Italian", @"code": @"italian" },
      @{@"name": @"Japanese", @"code": @"japanese"},
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name": @"Seafood", @"code": @"seafood"},
      @{@"name" : @"Soup", @"code": @"soup" },
      @{@"name": @"Taiwanese", @"code": @"taiwanese"},
      @{@"name": @"Thai", @"code": @"thai"},
      @{@"name": @"Vegetarian", @"code": @"vegetarian"}
    ];
}

@end
