//
//  MoviePlayerViewController.h
//  udisk-ios
//
//  Created by YangY on 2017/1/4.
//  Copyright © 2015年 xiaozhu. All rights reserved.
//

#import "MoviePlayerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface MoviePlayerViewController ()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *showView;//最外层View
@property (weak, nonatomic) IBOutlet UILabel *movieTitle;
@property (weak, nonatomic) IBOutlet UIButton *movieStateBtn;
@property (weak, nonatomic) IBOutlet UIButton *screenZoom;
@property (weak, nonatomic) IBOutlet UILabel *nowTime;
@property (weak, nonatomic) IBOutlet UILabel *totalTime;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (weak, nonatomic) IBOutlet UIProgressView *progress;


//播放器属性
@property(nonatomic,strong)AVPlayer *player; // 播放属性
@property(nonatomic,strong)AVPlayerItem *playerItem; // 播放属性
@property(nonatomic,strong)AVPlayerLayer *playerLayer;


@property(nonatomic,assign)CGPoint startPoint;
@property(nonatomic,assign)CGFloat systemVolume;
@property(nonatomic,strong)UISlider *volumeViewSlider;
@property(nonatomic,strong)UIActivityIndicatorView *activity; // 系统菊花

@end

@implementation MoviePlayerViewController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}
- (void)viewDidLoad {
    [super viewDidLoad];
//     [UIDevice setOrientation:UIDeviceOrientationLandscapeRight];
    // 创建AVPlayer
    
    self.playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:self.urlStr]];
    self.player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    
    _playerLayer.frame = self.showView.bounds;
    _playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.bgView.layer addSublayer:_playerLayer];
    
    
    [_player play];
    //AVPlayer播放完成通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];

    
    [self.playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];// 监听loadedTimeRanges属性

    [self createGesture];
    
    [self customVideoSlider];
    
    self.activity = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.center = _showView.center;
    [self.view addSubview:_activity];
    [_activity startAnimating];
    
//    //延迟线程
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [UIView animateWithDuration:0.5 animations:^{
            
            _showView.alpha = 0;
        }];
        
    });
    
    //计时器
    [NSTimer scheduledTimerWithTimeInterval:1.f target:self selector:@selector(Stack) userInfo:nil repeats:YES];

    [self.movieStateBtn setImage:[UIImage imageNamed:@"player_Play.png"] forState:UIControlStateNormal];
    [self.movieStateBtn setImage:[UIImage imageNamed:@"player_Stop.png"] forState:UIControlStateSelected];
}
#pragma mark ----------------------------------------------
#pragma mark - 返回按钮方法
- (IBAction)clickBackButton:(id)sender {
    [_player pause];
    [UIDevice setOrientation:UIInterfaceOrientationPortrait];
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
#pragma mark - 控制暂停和播放
- (IBAction)clickMoviewStste:(UIButton *)sender {
    if (sender.selected) {
        [_player play];
    } else {
        [_player pause];        
    }
    sender.selected =!sender.selected;
}
#pragma mark - 控制屏幕横竖
- (IBAction)clickScreenZoom:(id)sender {
    if ([UIDevice isOrientationLandscape]) {
        [UIDevice setOrientation:UIInterfaceOrientationPortrait];
    }else{
        [UIDevice setOrientation:UIInterfaceOrientationLandscapeLeft];
    }
    _playerLayer.frame = self.showView.bounds;
}
#pragma mark - slider滑动事件
- (IBAction)progressSlider:(id)sender {
    //拖动改变视频播放进度
    if (_player.status == AVPlayerStatusReadyToPlay) {
        
        //计算出拖动的当前秒数
        CGFloat total = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        
        NSInteger dragedSeconds = floorf(total * self.slider.value);
        
        //转换成CMTime才能给player来控制播放进度
        
        CMTime dragedCMTime = CMTimeMake(dragedSeconds, 1);
        
        [_player pause];
        
        [_player seekToTime:dragedCMTime completionHandler:^(BOOL finish){
            
            [_player play];
            
        }];
        self.movieStateBtn.selected = NO;
    }
}
#pragma mark - 播放结束
- (void)moviePlayDidEnd:(id)sender
{
    [_playerItem seekToTime:kCMTimeZero];
    [_player pause];
    self.movieStateBtn.selected = YES;
//    [UIDevice setOrientation:UIInterfaceOrientationPortrait];
//    [self dismissViewControllerAnimated:YES completion:^{
//        
//    }];
}
#pragma mark - 创建手势
- (void)createGesture
{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self.view addGestureRecognizer:tap];
}
#pragma mark - 轻拍方法
- (void)tapAction:(UITapGestureRecognizer *)tap
{
    if (_showView.alpha == 1) {
        [UIView animateWithDuration:0.5 animations:^{
            
            _showView.alpha = 0;
        }];
    } else if (_showView.alpha == 0){
        [UIView animateWithDuration:0.5 animations:^{
            
            _showView.alpha = 1;
        }];
    }
    if (_showView.alpha == 1) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.5 animations:^{
                
                _showView.alpha = 0;
            }];
            
        });
        
    }
}
#pragma mark ==============================================
- (BOOL)prefersStatusBarHidden
{
    return NO; // 返回NO表示要显示，返回YES将hiden
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        NSTimeInterval timeInterval = [self availableDuration];// 计算缓冲进度
        CMTime duration = self.playerItem.duration;
        CGFloat totalDuration = CMTimeGetSeconds(duration);
        [self.progress setProgress:timeInterval / totalDuration animated:NO];
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds = CMTimeGetSeconds(timeRange.start);
    float durationSeconds = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
- (void)customVideoSlider {
    UIGraphicsBeginImageContextWithOptions((CGSize){ 1, 1 }, NO, 0.0f);
    UIImage *transparentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    [self.slider setMinimumTrackImage:transparentImage forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:transparentImage forState:UIControlStateNormal];
}

#pragma mark - 计时器事件
- (void)Stack
{
    if (_playerItem.duration.timescale != 0) {

        _slider.maximumValue = 1;//音乐总共时长
        _slider.value = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);//当前进度
    
        //当前时长进度
        NSInteger proMin = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        self.nowTime.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];

        //duration 总时长
        NSInteger durMin = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总秒
        NSInteger durSec = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总分钟
        self.totalTime.text = [NSString stringWithFormat:@"%02ld:%02ld", durMin, durSec];
    }
    if (_player.status == AVPlayerStatusReadyToPlay) {
        [_activity stopAnimating];
    } else {
        [_activity startAnimating];
    }
    
}



#pragma mark - 滑动调整音量大小
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    if(event.allTouches.count == 1){
//        //保存当前触摸的位置
//        CGPoint point = [[touches anyObject] locationInView:self.view];
//        _startPoint = point;
//    }
//}
//-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
//    
//    if(event.allTouches.count == 1){
//        //计算位移
//        CGPoint point = [[touches anyObject] locationInView:self.view];
//        //        float dx = point.x - startPoint.x;
//        float dy = point.y - _startPoint.y;
//        int index = (int)dy;
//        if(index>0){
//            if(index%5==0){//每10个像素声音减一格
//                NSLog(@"%.2f",_systemVolume);
//                if(_systemVolume>0.1){
//                    _systemVolume = _systemVolume-0.05;
//                    [_volumeViewSlider setValue:_systemVolume animated:YES];
//                    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
//                }
//            }
//        }else{
//            if(index%5==0){//每10个像素声音增加一格
//                NSLog(@"+x ==%d",index);
//                NSLog(@"%.2f",_systemVolume);
//                if(_systemVolume>=0 && _systemVolume<1){
//                    _systemVolume = _systemVolume+0.05;
//                    [_volumeViewSlider setValue:_systemVolume animated:YES];
//                    [_volumeViewSlider sendActionsForControlEvents:UIControlEventTouchUpInside];
//                }
//            }
//        }
//        //亮度调节
//        //        [UIScreen mainScreen].brightness = (float) dx/self.view.bounds.size.width;
//    }
//}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
