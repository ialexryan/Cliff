//
//  ViewController.m
//  Cliff
//
//  Created by Alex Ryan on 7/27/14.
//  Copyright (c) 2014 Jaden Geller. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPress:(id)sender {
  UILocalNotification *notification = [[UILocalNotification alloc]init];
  notification.alertBody = @"Test";
  notification.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
  [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
