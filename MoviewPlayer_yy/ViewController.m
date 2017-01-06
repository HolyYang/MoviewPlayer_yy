//
//  ViewController.m
//  MoviewPlayer_yy
//
//  Created by YangY on 2017/1/6.
//  Copyright © 2017年 xiaozhu. All rights reserved.
//

#import "ViewController.h"
#import "MoviePlayerViewController.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)click:(id)sender {
    
    MoviePlayerViewController *movie = [[MoviePlayerViewController alloc]init];
    //    [self.navigationController pushViewController:movie animated:NO];
    //    movie.modalTransitionStyle = 0;
    NSString *urlStr=[[NSBundle mainBundle] pathForResource:@"111.mp4" ofType:nil];
    movie.urlStr = urlStr;
    [self presentViewController:movie animated:YES completion:^{
        
        
    }];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
