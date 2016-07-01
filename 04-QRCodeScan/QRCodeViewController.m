//
//  QRCodeViewController.m
//  04-QRCodeScan
//
//  Created by vera on 16/6/23.
//  Copyright © 2016年 vera. All rights reserved.
//

#import "QRCodeViewController.h"
#import <AVFoundation/AVFoundation.h>

#define kMainScreenWidth [UIScreen mainScreen].bounds.size.width
#define kMainScreenHeight [UIScreen mainScreen].bounds.size.height

@interface QRCodeViewController ()<AVCaptureMetadataOutputObjectsDelegate>
{
    AVCaptureVideoPreviewLayer *_previewLayer;
    
    BOOL _isUp;
    
    NSTimer *_timer;
}

/**
 *  负责输入与输出的交互
 */
@property (nonatomic, strong) AVCaptureSession *session;


@property (nonatomic, weak) UIImageView *qrImageView;
@property (nonatomic, weak) UIImageView *qrLineImageView;

@end

@implementation QRCodeViewController

- (UIImageView *)qrLineImageView
{
    if (!_qrLineImageView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"qr_scan_line"]];
        imageView.frame = CGRectMake(CGRectGetMinX(self.qrImageView.frame), CGRectGetMinY(self.qrImageView.frame) + 20, self.qrImageView.frame.size.width, 3);
        [self.view addSubview:imageView];
        
        _qrLineImageView = imageView;
    }
    
    return _qrLineImageView;
}


- (UIImageView *)qrImageView
{
    if (!_qrImageView)
    {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"smk"]];
        imageView.frame = CGRectMake(50, 90, self.view.frame.size.width - 2*50, self.view.frame.size.width - 2*50);
        [self.view addSubview:imageView];
        
        _qrImageView = imageView;
    }
    
    return _qrImageView;
}

- (AVCaptureSession *)session
{
    if (!_session)
    {
        //1.设备
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
        
        AVCaptureMetadataOutput *output = [[AVCaptureMetadataOutput alloc] init];
        //设置代理
        [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

        
        _session = [[AVCaptureSession alloc] init];
        
        

        //添加输入设备
        if ([_session canAddInput:input])
        {
            [_session addInput:input];
        }
        
        //添加输出设备
        if ([_session canAddOutput:output])
        {
            [_session addOutput:output];
        }
        
        //设置需要输出数据类型
        //AVMetadataObjectTypeQRCode表示只识别扫描的二维码
        output.metadataObjectTypes = @[AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code];
        
        //availableMetadataObjectTypes表示支持的所有的类型
        //output.metadataObjectTypes = output.availableMetadataObjectTypes;
        
        //设置可扫描的范围
        //CGRectMake（y的起点/屏幕的高，x的起点/屏幕的宽，扫描的区域的高/屏幕的高，扫描的区域的宽/屏幕的宽）
        //假如我们定义的扫描范围（x,y,w,h）则rectOfInterest=（y/H,x/W,h/H,w/W）
        output.rectOfInterest = CGRectMake(CGRectGetMinY(self.qrImageView.frame)/kMainScreenHeight, CGRectGetMinX(self.qrImageView.frame)/kMainScreenWidth, CGRectGetHeight(self.qrImageView.frame)/kMainScreenHeight, CGRectGetWidth(self.qrImageView.frame)/kMainScreenWidth);
    }
    
    return _session;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
     iOS7前：Zbar、Zxing。
     iOS7后：AVFoundation
     */
    
    self.view.backgroundColor = [UIColor whiteColor];
    
#if 0
    //虚拟设备
    AVCaptureDevice;
    //输入设备
    AVCaptureDeviceInput;
    //输出设备
    AVCaptureMetadataOutput;
    //负责输入与输出的交互
    AVCaptureSession;
    //显示拍摄的画面
    AVCaptureVideoPreviewLayer;
#endif
    
    _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.session];
    _previewLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:_previewLayer atIndex:0];
    
    
    
    //启动扫描
    [self.session startRunning];
    
    
    [self qrImageView];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(updateQrLineOriginY) userInfo:nil repeats:YES];
    
    
    
}

/**
 *  扫描动画
 */
- (void)updateQrLineOriginY
{
    
    CGRect frame = self.qrLineImageView.frame;
    
    CGFloat y = frame.origin.y;
    
    //如果到达最小值，则向下移动
    if (y <= CGRectGetMinY(self.qrImageView.frame) + 20)
    {
        _isUp = NO;
    }
    //如果到达最大值，则向上移动
    else if (y >= CGRectGetMaxY(self.qrImageView.frame) - 20)
    {
        _isUp = YES;
    }
    
    
    if (_isUp)
    {
        frame.origin.y--;
    }
    else
    {
        frame.origin.y++;
    }
    
    self.qrLineImageView.frame = frame;
}

#pragma mark - AVCaptureMetadataOutputObjectsDelegate
/**
 *  扫描到结果
 *
 *  @param captureOutput   <#captureOutput description#>
 *  @param metadataObjects <#metadataObjects description#>
 *  @param connection      <#connection description#>
 */
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    //已经扫描到二维码或者条形码
    if (metadataObjects.count > 0)
    {
        
        //停止扫描
        [self.session stopRunning];
        //暂停定时器
        [_timer setFireDate:[NSDate distantFuture]];
        
        //获取二维码或者条形码的信息
        AVMetadataMachineReadableCodeObject *object = [metadataObjects firstObject];
        //获取获取二维码或者条形码数据
        NSString *value = object.stringValue;
        
        [[[UIAlertView alloc] initWithTitle:@"扫描到结果了" message:value delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:nil, nil] show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.session startRunning];
    //启动定时器
    [_timer setFireDate:[NSDate distantPast]];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
