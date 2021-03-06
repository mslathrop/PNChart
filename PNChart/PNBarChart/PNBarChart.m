//
//  PNBarChart.m
//  PNChartDemo
//
//  Created by kevin on 11/7/13.
//  Copyright (c) 2013年 kevinzhow. All rights reserved.
//

#import "PNBarChart.h"
#import "PNColor.h"
#import "PNChartLabel.h"


@interface PNBarChart () {
    NSMutableArray *_labels;
}

- (UIColor *)barColorAtIndex:(NSUInteger)index;

@end

@implementation PNBarChart

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds   = YES;
        _showLabel           = YES;
        _barBackgroundColor  = PNLightGrey;
        _labelTextColor      = [UIColor grayColor];
        _labelFont           = [UIFont systemFontOfSize:11.0f];
        _labels              = [NSMutableArray array];
        _bars                = [NSMutableArray array];
        _xLabelSkip          = 1;
        _yLabelSum           = 4;
        _labelMarginTop      = 10;
        _chartMargin         = 15.0;
        _barRadius           = 2.0;
        _showChartBorder     = NO;
        _yChartLabelWidth    = 18;
        _xLabelHeight        = 50;
    }

    return self;
}


- (void)setYValues:(NSArray *)yValues
{
    _yValues = yValues;
    
    if (_yMaxValue) {
        _yValueMax = _yMaxValue;
    }else{
        [self getYValueMax:yValues];
    }
    

    _xLabelWidth = (self.frame.size.width - _chartMargin * 2) / [_yValues count];
}

- (void)getYValueMax:(NSArray *)yLabels
{
    int max = [[yLabels valueForKeyPath:@"@max.intValue"] intValue];
    
    _yValueMax = (int)max;
    
    if (_yValueMax == 0) {
        _yValueMax = _yMinValue;
    }
}


- (void)setYLabels:(NSArray *)yLabels
{
    
}


- (void)setXLabels:(NSArray *)xLabels
{
    _xLabels = xLabels;

    if (_showLabel) {
        _xLabelWidth = (self.frame.size.width - _chartMargin * 2) / [xLabels count];
    }
}


- (void)setStrokeColor:(UIColor *)strokeColor
{
    _strokeColor = strokeColor;
}

- (void)strokeChart {
    [self strokeChartWithAnimation:YES];
}

- (void)strokeChartWithAnimation:(BOOL)animated
{
    [self strokeChartWithAnimation:animated duration:0.5];
}

- (void)strokeChartWithAnimation:(BOOL)animated duration:(CGFloat)duration
{
    [self viewCleanupForCollection:_labels];
    //Add Labels
    if (_showLabel) {
        //Add x labels
        int labelAddCount = 0;
        for (int index = 0; index < _xLabels.count; index++) {
            labelAddCount += 1;
            
            if (labelAddCount == _xLabelSkip) {
                PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0, 0, xLabalAbsWidth, _xLabelHeight)];
                label.font = _labelFont;
                label.numberOfLines = 3;
                label.textColor = _labelTextColor;
                [label setTextAlignment:NSTextAlignmentCenter];
                
                // support attributed text
                NSObject *labelTextObject = _xLabels[index];
                if ([labelTextObject class] == [NSString class]) {
                    label.text = (NSString *)labelTextObject;
                }
                else {
                    label.attributedText = (NSAttributedString *)labelTextObject;
                }

                CGFloat labelXPosition  = (index * _xLabelWidth + _chartMargin + _xLabelWidth / 2.0 );
                CGFloat labelYPosition  = (self.frame.size.height - _xLabelHeight - xLabelPosAdj - _chartMargin + label.frame.size.height / 2.0 + _labelMarginTop);
                
                label.center = CGPointMake(labelXPosition, labelYPosition);
                labelAddCount = 0;
                
                [_labels addObject:label];
                [self addSubview:label];
            }
        }
        
        //Add y labels
        
        float yLabelSectionHeight = (self.frame.size.height - _chartMargin * 2 - _xLabelHeight) / _yLabelSum;
        
        for (int index = 0; index < _yLabelSum; index++) {
            
            NSString *labelText = nil;
            if (_yLabelFormatter) {
                labelText = _yLabelFormatter((float)_yValueMax * ( (_yLabelSum - index) / (float)_yLabelSum ));
            }
            
            PNChartLabel * label = [[PNChartLabel alloc] initWithFrame:CGRectMake(0,
                                                                                  yLabelSectionHeight * index + _chartMargin - yLabelHeight/2.0,
                                                                                  _yChartLabelWidth,
                                                                                  yLabelHeight)];
            label.font = _labelFont;
            label.textColor = _labelTextColor;
            [label setTextAlignment:NSTextAlignmentRight];
            label.text = labelText;

            [_labels addObject:label];
            [self addSubview:label];

        }
    }
    

    [self viewCleanupForCollection:_bars];
    
    
    //Add bars
    CGFloat chartCavanHeight = self.frame.size.height - _chartMargin * 2 - _xLabelHeight;
    NSInteger index = 0;

    for (NSNumber *valueString in _yValues) {
        float value = [valueString floatValue];

        float grade = (float)value / (float)_yValueMax;
        
        if (isnan(grade)) {
            grade = 0;
        }
        
        PNBar *bar;
        CGFloat barWidth;
        CGFloat barXPosition;
        
        if (_barWidth) {
            barWidth = _barWidth;
            barXPosition = index *  _xLabelWidth + _chartMargin + _xLabelWidth /2.0 - _barWidth /2.0;
        }else{
            barXPosition = index *  _xLabelWidth + _chartMargin + _xLabelWidth * 0.25;
            if (_showLabel) {
                barWidth = _xLabelWidth * 0.5;
                
            }
            else {
                barWidth = _xLabelWidth * 0.6;
                
            }
        }
        
        bar = [[PNBar alloc] initWithFrame:CGRectMake(barXPosition, //Bar X position
                                                      self.frame.size.height - chartCavanHeight - _xLabelHeight - _chartMargin, //Bar Y position
                                                      barWidth, // Bar witdh
                                                      chartCavanHeight)]; //Bar height
        
        //Change Bar Radius
        bar.barRadius = _barRadius;
        
        //Change Bar Background color
        bar.backgroundColor = _barBackgroundColor;
        
        //Bar StrokColor First
        if (self.strokeColor) {
            bar.barColor = self.strokeColor;
        }else{
            bar.barColor = [self barColorAtIndex:index];
        }
        
        //Height Of Bar
        [bar setGrade:grade animated:animated];
        
        //For Click Index
        bar.tag = index;
        
        [_bars addObject:bar];
        [self addSubview:bar];

        index += 1;
    }
    
    //Add chart border lines
    
    if (_showChartBorder) {
        _chartBottomLine = [CAShapeLayer layer];
        _chartBottomLine.lineCap      = kCALineCapButt;
        _chartBottomLine.fillColor    = [[UIColor whiteColor] CGColor];
        _chartBottomLine.lineWidth    = 1.0;
        _chartBottomLine.strokeEnd    = 0.0;
        
        UIBezierPath *progressline = [UIBezierPath bezierPath];
        
        [progressline moveToPoint:CGPointMake(_chartMargin, self.frame.size.height - _xLabelHeight - _chartMargin)];
        [progressline addLineToPoint:CGPointMake(self.frame.size.width - _chartMargin,  self.frame.size.height - _xLabelHeight - _chartMargin)];
        
        [progressline setLineWidth:1.0];
        [progressline setLineCapStyle:kCGLineCapSquare];
        _chartBottomLine.path = progressline.CGPath;
        
        
        _chartBottomLine.strokeColor = PNLightGrey.CGColor;
        
        if (animated) {
            CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathAnimation.duration = duration;
            pathAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            pathAnimation.fromValue = @0.0f;
            pathAnimation.toValue = @1.0f;
            [_chartBottomLine addAnimation:pathAnimation forKey:@"strokeEndAnimation"];
        }
        
        _chartBottomLine.strokeEnd = 1.0;
        
        [self.layer addSublayer:_chartBottomLine];
        
        //Add left Chart Line
        
        _chartLeftLine = [CAShapeLayer layer];
        _chartLeftLine.lineCap      = kCALineCapButt;
        _chartLeftLine.fillColor    = [[UIColor whiteColor] CGColor];
        _chartLeftLine.lineWidth    = 1.0;
        _chartLeftLine.strokeEnd    = 0.0;
        
        UIBezierPath *progressLeftline = [UIBezierPath bezierPath];
        
        [progressLeftline moveToPoint:CGPointMake(_chartMargin, self.frame.size.height - _xLabelHeight - _chartMargin)];
        [progressLeftline addLineToPoint:CGPointMake(_chartMargin,  _chartMargin)];
        
        [progressLeftline setLineWidth:1.0];
        [progressLeftline setLineCapStyle:kCGLineCapSquare];
        _chartLeftLine.path = progressLeftline.CGPath;
        
        
        _chartLeftLine.strokeColor = PNLightGrey.CGColor;
        
        
        if (animated) {
            CABasicAnimation *pathLeftAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
            pathLeftAnimation.duration = duration;
            pathLeftAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            pathLeftAnimation.fromValue = @0.0f;
            pathLeftAnimation.toValue = @1.0f;
            [_chartLeftLine addAnimation:pathLeftAnimation forKey:@"strokeEndAnimation"];
        }
        
        _chartLeftLine.strokeEnd = 1.0;
        
        [self.layer addSublayer:_chartLeftLine];
    }
}


- (void)viewCleanupForCollection:(NSMutableArray *)array
{
    if (array.count) {
        [array makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [array removeAllObjects];
    }
}


#pragma mark - Class extension methods

- (UIColor *)barColorAtIndex:(NSUInteger)index
{
    if ([self.strokeColors count] == [self.yValues count]) {
        return self.strokeColors[index];
    }
    else {
        return self.strokeColor;
    }
}


#pragma mark - Touch detection

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchPoint:touches withEvent:event];
    [super touchesBegan:touches withEvent:event];
}


- (void)touchPoint:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Get the point user touched
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    UIView *subview = [self hitTest:touchPoint withEvent:nil];
    
    if ([subview isKindOfClass:[PNBar class]] && [self.delegate respondsToSelector:@selector(userClickedOnBarCharIndex:touchPoint:)]) {
        [self.delegate userClickedOnBarCharIndex:subview.tag touchPoint:touchPoint];
    }
    else if ([subview isKindOfClass:[PNBar class]] && [self.delegate respondsToSelector:@selector(userClickedOnBarCharIndex:)]) {
        [self.delegate userClickedOnBarCharIndex:subview.tag];
    }
}


@end
