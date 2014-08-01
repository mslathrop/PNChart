//
//  PNChartDelegate.h
//  PNChartDemo
//
//  Created by kevinzhow on 13-12-11.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PNChartDelegate <NSObject>

@optional

/**
 * When user click on the chart line
 *
 */
- (void)userClickedOnLinePoint:(CGPoint)point lineIndex:(NSInteger)lineIndex;

/**
 * When user click on the chart line key point
 *
 */
- (void)userClickedOnLineKeyPoint:(CGPoint)point lineIndex:(NSInteger)lineIndex andPointIndex:(NSInteger)pointIndex;

/**
 * When user click on a chart bar
 *
 */
- (void)userClickedOnBarCharIndex:(NSInteger)barIndex;

- (void)userClickedOnBarCharIndex:(NSInteger)barIndex touchPoint:(CGPoint)touchPoint;

@end