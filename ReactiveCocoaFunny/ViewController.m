//
//  ViewController.m
//  ReactiveCocoaFunny
//
//  Created by 王召洲 on 2016/10/14.
//  Copyright © 2016年 wyzc. All rights reserved.
//

#import "ViewController.h"
#import <ReactiveCocoa.h>

@protocol makeApp <NSObject>

-(void)makeApp;

@end

@interface ViewController ()
@property (nonatomic,strong) NSString * value1;
@property (nonatomic,copy) NSString * valueA;
@property (nonatomic,copy) NSString * valueB;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    @weakify(self);
    
    // subscribeNext 主动请求信号
    [RACObserve(self, value1) subscribeNext:^(id x) {
        @strongify(self);
        NSLog(@"valueChanged -> %@",x);
    }];
    
    RACSignal *singSignal = [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:@"唱歌"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    // map 也会触发信号发送事件
    RAC(self,value1) = [singSignal map:^NSString *(NSString * value) {
        if ([value isEqualToString:@"唱歌"]) {
            return @"跳舞";
        }
        return nil;
    }];
    NSLog(@"value %@",self.value1);
    
    // 管道
    RACChannelTerminal *channelA = RACChannelTo(self, valueA);
    RACChannelTerminal *channelB = RACChannelTo(self, valueB);
    
    // 通道A对接的属性发生改变
    [[channelA map:^id(NSString *value) {
        if ([value isEqualToString:@"西"]) {
            return @"东";
        }
        return value;
    }] subscribe:channelB];
    
    [[channelB map:^id(NSString *value) {
        if ([value isEqualToString:@"左"]) {
            return @"右";
        }
        return value;
    }] subscribe:channelA];
    
    
    [[RACObserve(self, valueA) filter:^BOOL(id value) {
        return value ? YES : NO;
    }] subscribeNext:^(NSString* x) {
        NSLog(@"你向%@", x);
    }];
    
    [[RACObserve(self, valueB) filter:^BOOL(id value) {
        return value ? YES : NO;
    }] subscribeNext:^(NSString* x) {
        NSLog(@"他向%@", x);
    }];
    self.valueA = @"西";
   // self.valueB = @"左";
    
    
    RACSignal *signalA = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"我恋爱啦"];
        [subscriber sendCompleted];
        return nil;
    }];
    
    RACSignal *signalB = [RACSignal createSignal:^RACDisposable *(id subscriber) {
        [subscriber sendNext:@"我结婚啦"];
        [subscriber sendCompleted];
        return nil;
    }];
    [[signalA concat:signalB] subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
    // combineLatest 将最新的信号 合并
    // merge 合并（任何信号来时，都会触发block）
    // zip 信号压缩
    // map 信号映射
    // flattenMap 内部信号映射
    // replay 多次发射信号
    // retry 之前的信号多次发射
    // takeUntil 直到某一条件达成前，一直发射
    RACSignal *signal = [[RACSignal createSignal:^RACDisposable *(id subscriber) {
        
        [subscriber sendNext:@"石"];
        return nil;
    }] map:^id(NSString* value) {
        if ([value isEqualToString:@"石"]) {
            return @"金";
        }
        return value;
    }];
    
    [signal subscribeNext:^(id x) {
        NSLog(@"%@",x);
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.value1 = [NSString stringWithFormat:@"-->%d",arc4random_uniform(30)];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
