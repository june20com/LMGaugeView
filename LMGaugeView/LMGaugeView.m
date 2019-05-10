//
//  LMGaugeView.m
//  LMGaugeView
//
//  Created by LMinh on 01/08/2014.
//  Copyright (c) 2014 LMinh. All rights reserved.
//

#import "LMGaugeView.h"

#define kDefaultStartAngle                      M_PI_4 * 3
#define kDefaultEndAngle                        M_PI_4 + 2 * M_PI
#define kDefaultMinValue                        0
#define kDefaultMaxValue                        120
#define kDefaultLimitValue                      50
#define kDefaultNumOfDivisions                  6
#define kDefaultNumOfSubDivisions               10

#define kDefaultRingThickness                   15
#define kDefaultRingBackgroundColor             [UIColor colorWithWhite:0.9 alpha:1]
#define kDefaultRingColor                       [UIColor colorWithRed:76.0/255 green:217.0/255 blue:100.0/255 alpha:1]

#define kDefaultDivisionsRadius                 1.25
#define kDefaultDivisionsColor                  [UIColor colorWithWhite:0.5 alpha:1]
#define kDefaultDivisionsPadding                12

#define kDefaultSubDivisionsRadius              0.75
#define kDefaultSubDivisionsColor               [UIColor colorWithWhite:0.5 alpha:0.5]

#define kDefaultLimitDotRadius                  2
#define kDefaultLimitDotColor                   [UIColor redColor]

#define kDefaultValueTextColor                  [UIColor colorWithWhite:0.1 alpha:1]
#define kDefaultMinMaxValueFont                 [UIFont fontWithName:@"HelveticaNeue" size:12]
#define kDefaultMinMaxValueTextColor            [UIColor colorWithWhite:0.3 alpha:1]

#define kDefaultUnitOfMeasurement               @"km/h"
#define kDefaultUnitOfMeasurementFont           [UIFont boldSystemFontOfSize:10]
#define kDefaultUnitOfMeasurementTextColor      [UIColor colorWithWhite:0.3 alpha:1]

@interface LMGaugeView ()

// For calculation
@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) CGFloat divisionUnitAngle;
@property (nonatomic, assign) CGFloat divisionUnitValue;

@property (nonatomic, strong) CAShapeLayer *progressLayer;
@property (nonatomic, strong) UILabel *valueLabel;
@property (nonatomic, strong) UILabel *unitOfMeasurementLabel;
@property (nonatomic, strong) UILabel *minValueLabel;
@property (nonatomic, strong) UILabel *maxValueLabel;

@end

@implementation LMGaugeView

#pragma mark - UIView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.contentMode = UIViewContentModeRedraw;
    
    if (!self.backgroundColor) {
        self.backgroundColor = [UIColor clearColor];
    }
    
    // Set default values
    _startAngle = kDefaultStartAngle;
    _endAngle = kDefaultEndAngle;
    
    _value = kDefaultMinValue;
    _minValue = kDefaultMinValue;
    _maxValue = kDefaultMaxValue;
    _limitValue = kDefaultLimitValue;
    _fillRing = YES;
    _numOfDivisions = kDefaultNumOfDivisions;
    _numOfSubDivisions = kDefaultNumOfSubDivisions;
    
    // Ring
    _ringThickness = kDefaultRingThickness;
    _ringBackgroundColor = kDefaultRingBackgroundColor;
    
    // Divisions
    _divisionsRadius = kDefaultDivisionsRadius;
    _divisionsColor = kDefaultDivisionsColor;
    _divisionsPadding = kDefaultDivisionsPadding;
    
    // Subdivisions
    _subDivisionsRadius = kDefaultSubDivisionsRadius;
    _subDivisionsColor = kDefaultSubDivisionsColor;
    
    // Limit dot
    _showLimitDot = YES;
    _limitDotRadius = kDefaultLimitDotRadius;
    _limitDotColor = kDefaultLimitDotColor;
    
    // Value Text
    _valueFont = [UIFont monospacedDigitSystemFontOfSize:10 weight:UIFontWeightBold];

    _valueFormatter = [[NSNumberFormatter alloc] init];
    _valueFormatter.numberStyle = NSNumberFormatterDecimalStyle;

    _valueTextColor = kDefaultValueTextColor;
    _showMinMaxValue = YES;
    _minMaxValueFont = kDefaultMinMaxValueFont;
    _minMaxValueTextColor = kDefaultMinMaxValueTextColor;
    
    // Unit Of Measurement
    _showUnitOfMeasurement = YES;
    _unitOfMeasurement = kDefaultUnitOfMeasurement;
    _unitOfMeasurementFont = kDefaultUnitOfMeasurementFont;
    _unitOfMeasurementTextColor = kDefaultUnitOfMeasurementTextColor;

    // Value label
    _valueLabel = [[UILabel alloc] init];
    _valueLabel.backgroundColor = [UIColor clearColor];
    _valueLabel.textAlignment = NSTextAlignmentCenter;
    _valueLabel.text = [_valueFormatter stringFromNumber:@(_value)];
    _valueLabel.font = _valueFont;
    _valueLabel.adjustsFontSizeToFitWidth = NO;
    _valueLabel.textColor = _valueTextColor;
    [self addSubview:_valueLabel];

    // Unit of measurement label
    _unitOfMeasurementLabel = [[UILabel alloc] init];
    _unitOfMeasurementLabel.backgroundColor = [UIColor clearColor];
    _unitOfMeasurementLabel.textAlignment = NSTextAlignmentCenter;
    _unitOfMeasurementLabel.text = _unitOfMeasurement;
    _unitOfMeasurementLabel.font = _unitOfMeasurementFont;
    _unitOfMeasurementLabel.adjustsFontSizeToFitWidth = YES;
    _unitOfMeasurementLabel.minimumScaleFactor = 0.8f;
    _unitOfMeasurementLabel.textColor = _unitOfMeasurementTextColor;
    _unitOfMeasurementLabel.hidden = !_showUnitOfMeasurement;
    [self addSubview:_unitOfMeasurementLabel];

    // Min/max value labels
    _minValueLabel = [[UILabel alloc] init];
    _minValueLabel.backgroundColor = [UIColor clearColor];
    _minValueLabel.textAlignment = NSTextAlignmentLeft;
    _minValueLabel.text = [_valueFormatter stringFromNumber:@(_minValue)];
    _minValueLabel.font = _minMaxValueFont;
    _minValueLabel.textColor = _minMaxValueTextColor;
    _minValueLabel.hidden = !_showMinMaxValue;
    [self addSubview:_minValueLabel];

    _maxValueLabel = [[UILabel alloc] init];
    _maxValueLabel.backgroundColor = [UIColor clearColor];
    _maxValueLabel.textAlignment = NSTextAlignmentRight;
    _maxValueLabel.text = [_valueFormatter stringFromNumber:@(_maxValue)];
    _maxValueLabel.font = _minMaxValueFont;
    _maxValueLabel.textColor = _minMaxValueTextColor;
    _maxValueLabel.hidden = !_showMinMaxValue;
    [self addSubview:_maxValueLabel];

    _progressLayer = [CAShapeLayer layer];
    _progressLayer.contentsScale = [[UIScreen mainScreen] scale];
    _progressLayer.fillColor = [UIColor clearColor].CGColor;
    _progressLayer.lineCap = kCALineJoinBevel;
    _progressLayer.lineJoin = kCALineJoinBevel;
    _progressLayer.strokeEnd = 0;
    _progressLayer.lineWidth = _ringThickness;
    [self.layer addSublayer:_progressLayer];
}


#pragma mark - ANIMATION

- (void)strokeGauge
{
    /*!
     *  Set progress for ring layer
     */
    CGFloat progress = _maxValue ? (_value - _minValue)/(_maxValue - _minValue) : 0;

    if (_fillRing)
        _progressLayer.strokeEnd = progress;
    else
    {
        const CGFloat delta = 0.05;
        _progressLayer.strokeStart = progress-delta;
        _progressLayer.strokeEnd = progress+delta;
    }

    /*!
     *  Set ring stroke color
     */
    UIColor *ringColor = kDefaultRingColor;
    if (_delegate && [_delegate respondsToSelector:@selector(gaugeView:ringStokeColorForValue:)]) {
        ringColor = [_delegate gaugeView:self ringStokeColorForValue:_value];
    }
    _progressLayer.strokeColor = ringColor.CGColor;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect bounds = self.bounds;
    CGPoint center = CGPointMake(CGRectGetWidth(bounds)/2, CGRectGetHeight(bounds)/2);
    CGFloat ringRadius = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds))/2 - _ringThickness/2;

    _progressLayer.frame = CGRectMake(center.x - ringRadius - _ringThickness/2,
                                      center.y - ringRadius - _ringThickness/2,
                                      (ringRadius + _ringThickness/2) * 2,
                                      (ringRadius + _ringThickness/2) * 2);
    _progressLayer.bounds = _progressLayer.frame;
    UIBezierPath *arcPath = [UIBezierPath bezierPathWithArcCenter:_progressLayer.position
                                                                radius:ringRadius
                                                            startAngle:_startAngle
                                                              endAngle:_endAngle
                                                             clockwise:YES];
    _progressLayer.path = arcPath.CGPath;

    // Layout _valueLabel
    CGFloat insetX = _numOfDivisions == 0 ? _divisionsPadding : _ringThickness + _divisionsPadding * 2 + _divisionsRadius;
    CGRect valueLabelFrame = CGRectInset(_progressLayer.frame, insetX, insetX);
    valueLabelFrame = CGRectOffset(valueLabelFrame, 0, _showUnitOfMeasurement ? -_divisionsPadding/2 : 0);
    _valueLabel.frame = valueLabelFrame;

    // Layout _minValueLabel
    CGFloat dotRadius = ringRadius - _ringThickness/2 - _divisionsPadding - _divisionsRadius/2;

    CGPoint minDotCenter = CGPointMake(dotRadius * cos(_startAngle) + center.x, dotRadius * sin(_startAngle) + center.y);
    _minValueLabel.frame = CGRectMake(minDotCenter.x + 8, minDotCenter.y - 20, 40, 20);

    // Layout maxValueLabel
    CGPoint maxDotCenter = CGPointMake(dotRadius * cos(_endAngle) + center.x, dotRadius * sin(_endAngle) + center.y);
    _maxValueLabel.frame = CGRectMake(maxDotCenter.x - 8 - 40, maxDotCenter.y - 20, 40, 20);

    _unitOfMeasurementLabel.frame = CGRectMake(valueLabelFrame.origin.x,
                                               valueLabelFrame.origin.y + CGRectGetHeight(valueLabelFrame) - 10,
                                               CGRectGetWidth(valueLabelFrame),
                                               20);


}

#pragma mark - CUSTOM DRAWING

- (void)drawRect:(CGRect)rect
{
     CGRect bounds = self.bounds;

     // Prepare drawing
    _divisionUnitValue = _numOfDivisions ? (_maxValue - _minValue)/_numOfDivisions : 0;
    _divisionUnitAngle = _numOfDivisions ? ABS(_endAngle - _startAngle)/_numOfDivisions : 0;
    CGPoint center = CGPointMake(CGRectGetWidth(bounds)/2, CGRectGetHeight(bounds)/2);
    CGFloat ringRadius = MIN(CGRectGetWidth(bounds), CGRectGetHeight(bounds))/2 - _ringThickness/2;
    CGFloat dotRadius = ringRadius - _ringThickness/2 - _divisionsPadding - _divisionsRadius/2;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /*!
     *  Draw the ring background
     */
    CGContextSetLineWidth(context, _ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, 0, M_PI * 2, 0);
    CGContextSetStrokeColorWithColor(context, [_ringBackgroundColor colorWithAlphaComponent:0.3].CGColor);
    CGContextStrokePath(context);
    
    /*!
     *  Draw the ring progress background
     */
    CGContextSetLineWidth(context, _ringThickness);
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, ringRadius, _startAngle, _endAngle, 0);
    CGContextSetStrokeColorWithColor(context, _ringBackgroundColor.CGColor);
    CGContextStrokePath(context);
    
    /*!
     *  Draw divisions and subdivisions
     */
    for (int i = 0; i <= _numOfDivisions && _numOfDivisions != 0; i++)
    {
        if (i != _numOfDivisions)
        {
            for (int j = 0; j <= _numOfSubDivisions && _numOfSubDivisions != 0; j++)
            {
                // Subdivisions
                CGFloat value = i * _divisionUnitValue + j * _divisionUnitValue/_numOfSubDivisions + _minValue;
                CGFloat angle = [self angleFromValue:value];
                CGPoint dotCenter = CGPointMake(dotRadius * cos(angle) + center.x, dotRadius * sin(angle) + center.y);
                [self drawDotAtContext:context
                                center:dotCenter
                                radius:_subDivisionsRadius
                             fillColor:_subDivisionsColor.CGColor];
            }
        }
        
        // Divisions
        CGFloat value = i * _divisionUnitValue + _minValue;
        CGFloat angle = [self angleFromValue:value];
        CGPoint dotCenter = CGPointMake(dotRadius * cos(angle) + center.x, dotRadius * sin(angle) + center.y);
        [self drawDotAtContext:context
                        center:dotCenter
                        radius:_divisionsRadius
                     fillColor:_divisionsColor.CGColor];
    }
    
    /*!
     *  Draw the limit dot
     */
    if (_showLimitDot && _numOfDivisions != 0)
    {
        CGFloat angle = [self angleFromValue:_limitValue];
        CGPoint dotCenter = CGPointMake(dotRadius * cos(angle) + center.x, dotRadius * sin(angle) + center.y);
        [self drawDotAtContext:context
                        center:dotCenter
                        radius:_limitDotRadius
                     fillColor:_limitDotColor.CGColor];
    }
}


#pragma mark - SUPPORT

- (CGFloat)angleFromValue:(CGFloat)value
{
    CGFloat level = _divisionUnitValue ? (value - _minValue)/_divisionUnitValue : 0;
    CGFloat angle = level * _divisionUnitAngle + _startAngle;
    return angle;
}

- (void)drawDotAtContext:(CGContextRef)context
                  center:(CGPoint)center
                  radius:(CGFloat)radius
               fillColor:(CGColorRef)fillColor
{
    CGContextBeginPath(context);
    CGContextAddArc(context, center.x, center.y, radius, 0, M_PI * 2, 0);
    CGContextSetFillColorWithColor(context, fillColor);
    CGContextFillPath(context);
}


#pragma mark - PROPERTIES

- (void)setValue:(CGFloat)value
{
    _value = MIN(value, _maxValue);
    _value = MAX(_value, _minValue);
    
    /*!
     *  Set text for value label
     */
    _valueLabel.text = [_valueFormatter stringFromNumber:@(value)];

    /*!
     *  Trigger the stoke animation of ring layer.
     */
    [self strokeGauge];
}

- (void)setMinValue:(CGFloat)minValue
{
    if (_minValue != minValue && minValue < _maxValue) {
        _minValue = minValue;
        [self setNeedsDisplay];
    }
}

- (void)setMaxValue:(CGFloat)maxValue
{
    if (_maxValue != maxValue && maxValue > _minValue) {
        _maxValue = maxValue;
        [self setNeedsDisplay];
    }
}

- (void)setLimitValue:(CGFloat)limitValue
{
    if (_limitValue != limitValue && limitValue >= _minValue && limitValue <= _maxValue) {
        _limitValue = limitValue;
        [self setNeedsDisplay];
    }
}

- (void)setNumOfDivisions:(NSUInteger)numOfDivisions
{
    if (_numOfDivisions != numOfDivisions) {
        _numOfDivisions = numOfDivisions;
        [self setNeedsDisplay];
    }
}

- (void)setNumOfSubDivisions:(NSUInteger)numOfSubDivisions
{
    if (_numOfSubDivisions != numOfSubDivisions) {
        _numOfSubDivisions = numOfSubDivisions;
        [self setNeedsDisplay];
    }
}

- (void)setRingThickness:(CGFloat)ringThickness
{
    if (_ringThickness != ringThickness) {
        _ringThickness = ringThickness;
        _progressLayer.lineWidth = _ringThickness;
        [self setNeedsDisplay];
    }
}

- (void)setRingBackgroundColor:(UIColor *)ringBackgroundColor
{
    if (_ringBackgroundColor != ringBackgroundColor) {
        _ringBackgroundColor = ringBackgroundColor;
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsRadius:(CGFloat)divisionsRadius
{
    if (_divisionsRadius != divisionsRadius) {
        _divisionsRadius = divisionsRadius;
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsColor:(UIColor *)divisionsColor
{
    if (_divisionsColor != divisionsColor) {
        _divisionsColor = divisionsColor;
        [self setNeedsDisplay];
    }
}

- (void)setDivisionsPadding:(CGFloat)divisionsPadding
{
    if (_divisionsPadding != divisionsPadding) {
        _divisionsPadding = divisionsPadding;
        [self setNeedsDisplay];
    }
}

- (void)setSubDivisionsRadius:(CGFloat)subDivisionsRadius
{
    if (_subDivisionsRadius != subDivisionsRadius) {
        _subDivisionsRadius = subDivisionsRadius;
        [self setNeedsDisplay];
    }
}

- (void)setSubDivisionsColor:(UIColor *)subDivisionsColor
{
    if (_subDivisionsColor != subDivisionsColor) {
        _subDivisionsColor = subDivisionsColor;
        [self setNeedsDisplay];
    }
}

- (void)setShowLimitDot:(BOOL)showLimitDot
{
    if (_showLimitDot != showLimitDot) {
        _showLimitDot = showLimitDot;
        [self setNeedsDisplay];
    }
}

- (void)setLimitDotRadius:(CGFloat)limitDotRadius
{
    if (_limitDotRadius != limitDotRadius) {
        _limitDotRadius = limitDotRadius;
        [self setNeedsDisplay];
    }
}

- (void)setLimitDotColor:(UIColor *)limitDotColor
{
    if (_limitDotColor != limitDotColor) {
        _limitDotColor = limitDotColor;
        [self setNeedsDisplay];
    }
}

- (void)setValueFont:(UIFont *)valueFont
{
    if (_valueFont != valueFont) {
        _valueFont = valueFont;
        _valueLabel.font = _valueFont;
    }
}

- (void)setValueTextColor:(UIColor *)valueTextColor
{
    if (_valueTextColor != valueTextColor) {
        _valueTextColor = valueTextColor;

        _valueLabel.textColor = _valueTextColor;
    }
}

- (void)setShowMinMaxValue:(BOOL)showMinMaxValue
{
    if (_showMinMaxValue != showMinMaxValue) {
        _showMinMaxValue = showMinMaxValue;
        _minValueLabel.hidden = !showMinMaxValue;
        _maxValueLabel.hidden = !showMinMaxValue;
    }
}

- (void)setMinMaxValueFont:(UIFont *)minMaxValueFont
{
    if (_minMaxValueFont != minMaxValueFont) {
        _minMaxValueFont = minMaxValueFont;
        _minValueLabel.font = minMaxValueFont;
        _maxValueLabel.font = minMaxValueFont;
    }
}

- (void)setMinMaxValueTextColor:(UIColor *)minMaxValueTextColor
{
    if (_minMaxValueTextColor != minMaxValueTextColor) {
        _minMaxValueTextColor = minMaxValueTextColor;
        _minValueLabel.textColor = minMaxValueTextColor;
        _maxValueLabel.textColor = minMaxValueTextColor;
    }
}

- (void)setShowUnitOfMeasurement:(BOOL)showUnitOfMeasurement
{
    if (_showUnitOfMeasurement != showUnitOfMeasurement) {
        _showUnitOfMeasurement = showUnitOfMeasurement;
        _unitOfMeasurementLabel.hidden = !_showUnitOfMeasurement;
    }
}

- (void)setUnitOfMeasurement:(NSString *)unitOfMeasurement
{
    if (_unitOfMeasurement != unitOfMeasurement) {
        _unitOfMeasurement = unitOfMeasurement;
        _unitOfMeasurementLabel.text = _unitOfMeasurement;
    }
}

- (void)setUnitOfMeasurementFont:(UIFont *)unitOfMeasurementFont
{
    if (_unitOfMeasurementFont != unitOfMeasurementFont) {
        _unitOfMeasurementFont = unitOfMeasurementFont;
        _unitOfMeasurementLabel.font = _unitOfMeasurementFont;
    }
}

- (void)setUnitOfMeasurementTextColor:(UIColor *)unitOfMeasurementTextColor
{
    if (_unitOfMeasurementTextColor != unitOfMeasurementTextColor) {
        _unitOfMeasurementTextColor = unitOfMeasurementTextColor;
        _unitOfMeasurementLabel.textColor = _unitOfMeasurementTextColor;
    }
}

@end
