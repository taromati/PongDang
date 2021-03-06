//
//  ViewController.m
//  PongDang
//
//  Created by Cheon Park on 2014. 6. 29..
//  Copyright (c) 2014년 northPenguin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
            
- (void)viewDidLoad {
    [super viewDidLoad];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.nowHanGang.font = [UIFont fontWithName:@"NanumMyeongjoOTF" size:20];

    [self setTempLoadForState];
    [self setProgressView];
    [self getTempStart];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.apiReturnData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.apiReturnData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"URL Connection Failed!");
    currentConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    id tempJson = [NSJSONSerialization JSONObjectWithData:self.apiReturnData options:0 error:nil];
    self.temp   = [[tempJson objectForKey:@"temp"]floatValue];

    NSMutableAttributedString *tempText = [[NSMutableAttributedString alloc]initWithString:
                                           [NSString stringWithFormat:@"%.1f", self.temp]];
    NSMutableAttributedString *tempUnit = [[NSMutableAttributedString alloc]initWithString:@"℃"];

    [tempText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:nil size:30],
                              NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, [tempText length])];
    [tempUnit setAttributes:@{NSFontAttributeName:[UIFont fontWithName:nil size:12],
                              NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, [tempUnit length])];
    [tempText appendAttributedString:tempUnit];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.84 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [self getTempEnd:tempText];
    });
}

- (IBAction)tempLoad:(id)sender {
    NSMutableAttributedString *waitingText = [[NSMutableAttributedString alloc]initWithString:@"측정중"];
    [waitingText setAttributes:@{NSFontAttributeName:[UIFont fontWithName:nil size:20],
                                 NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, [waitingText length])];
    
    [self.progressView setHidden:NO];
    [self.tempLoad setAttributedTitle:waitingText forState:UIControlStateNormal];
    [self getTempStart];
}

- (IBAction)exportButton:(id)sender {
    if (![self presentedViewController]) {
        NSString *tempStringExport = [NSString stringWithFormat:@"친구야 한강가자! 지금 수온 %.1f℃래~", self.temp];
        KakaoLink *kakaoLink = [KakaoLink new];

        UIActivityViewController *exportController = [[UIActivityViewController alloc]initWithActivityItems:@[tempStringExport]
                                                                                      applicationActivities:@[kakaoLink]];

        [self presentViewController:exportController animated:YES completion:nil];
    }
}

- (IBAction)whoButton:(id)sender {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Setting for progressView and tempLoadButton
- (void)setProgressView {
    [self.progressView setSecondaryColor:[self colorFromHexString:@"#D3DBDE" withAlpha:0.42f]];
    [self.progressView setShowPercentage:NO];
}

- (void)setTempLoadForState {
    UIImage *highlightImage = [self translucentImageFromImage:[UIImage imageNamed:@"dropWater.png"] withAlpha:0.4f];
    UIImage *normalImage = [self translucentImageFromImage:[UIImage imageNamed:@"dropWater.png"] withAlpha:0.6f];
    UIImage *selectedImage = [self translucentImageFromImage:[UIImage imageNamed:@"dropWater.png"] withAlpha:0.0f];
    
    [self.tempLoad setBackgroundImage:highlightImage forState:UIControlStateHighlighted];
    [self.tempLoad setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.tempLoad setBackgroundImage:selectedImage forState:UIControlStateSelected];
}

#pragma mark - Start End get temperature
- (void)getTempStart {
    [self.loadingBack setHidden:NO];
    [self.progressView setIndeterminate:YES];
    NSURL *tempURL = [NSURL URLWithString:@"http://hangang.dkserver.wo.tc"];
    NSURLRequest *tempRequest = [NSURLRequest requestWithURL:tempURL];
    
    if (currentConnection) {
        [currentConnection cancel];
        currentConnection = nil;
        self.apiReturnData = nil;
    }
    currentConnection = [[NSURLConnection alloc]initWithRequest:tempRequest delegate:self];
    self.apiReturnData = [NSMutableData data];
}

- (void)getTempEnd:(NSMutableAttributedString *)tempText {
    [self.loadingBack setHidden:YES];
    [self.tempLoad setAttributedTitle:tempText forState:UIControlStateNormal];
    [self.progressView setHidden:YES];
    currentConnection = nil;
}

#pragma mark - Custom Function
- (UIColor *)colorFromHexString:(NSString *)hexString withAlpha:(CGFloat)alpha {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:alpha];
}

- (UIImage *)translucentImageFromImage:(UIImage *)image withAlpha:(CGFloat)alpha {
    CGRect rect = CGRectZero;
    rect.size = image.size;
    
    UIGraphicsBeginImageContext(image.size);
    [image drawInRect:rect blendMode:kCGBlendModeScreen alpha:alpha];
    UIImage * translucentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return translucentImage;
}

@end

