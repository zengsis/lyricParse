//
//  ViewController.m
//  歌词解析
//
//  Created by apple on 15/8/28.
//  Copyright (c) 2015年 apple. All rights reserved.
//

#import "ViewController.h"

@interface  SingleLineLyrics : NSObject<NSCopying>

@property(nonatomic)  NSString *lyricText;
@property(nonatomic,assign) NSUInteger startTime;

@end
@implementation SingleLineLyrics
-(id)copyWithZone:(NSZone *)zone
{
    SingleLineLyrics *newObj = [[self class]allocWithZone:zone];
    newObj.startTime=self.startTime;
    newObj.lyricText=self.lyricText;
    return newObj;
}
-(NSComparisonResult)compare:(SingleLineLyrics *)other
{
    if(self.startTime<other.startTime)
    {
        return NSOrderedAscending;
    }else if (self.startTime>other.startTime)
    {
        return NSOrderedDescending;
    }
    else
    {
        return NSOrderedSame;
    }
}
@end

@interface ViewController ()
{
    NSString *_lyricsFilePath;
    NSMutableArray *_lyricsLinesArray;
    NSTimer *_timer;
    NSUInteger _timePasted;
}
@property (weak, nonatomic) IBOutlet UILabel *lyricLabel;


@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 _lyricsFilePath=@"/Users/apple/Desktop/yunxingziliao/geci.lrc";
    _lyricsLinesArray=[NSMutableArray array];
}
-(void)parseWholeLyricsWithData:(NSData *)data
{
 [_lyricsLinesArray removeAllObjects];
    NSString *wholeLyricsString=[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *linesArray=[wholeLyricsString componentsSeparatedByString:@"\n"];
    for(NSString *line in linesArray){
        NSString *trimmedLine=[line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [trimmedLine lowercaseString];
        if(trimmedLine.length<=5) continue;
        if([trimmedLine hasPrefix:@"[ti:"]||[trimmedLine hasPrefix:@"[ar:"]||[trimmedLine hasPrefix:@"[al:"]||[trimmedLine hasPrefix:@"[t_t"])
        {
            continue;
        }
        [self parseOneLineLyricWithString:trimmedLine];
    }
    [_lyricsLinesArray sortUsingSelector:@selector(compare:)];
}
-(void)parseOneLineLyricWithString:(NSString *)line
{
    if(![line hasPrefix:@"["]) return;
    NSUInteger timeStampEndPos=[line rangeOfString:@"]" options:NSBackwardsSearch].location;
        if(timeStampEndPos < 9) return;
    NSString *timeStampsStr=[line substringToIndex:(timeStampEndPos+1)];
NSString *lyricLineStr=[line substringFromIndex:(timeStampEndPos+1)];
NSArray *timeStampArray=[timeStampsStr componentsSeparatedByString:@"]"];
    for(NSString *singleTimeStamp in timeStampArray)
    {
        if(![singleTimeStamp hasPrefix:@"["]) continue;
        NSString *timeStampStr =[singleTimeStamp substringFromIndex:1];
        NSUInteger startTime=[self milliSecondsFromTimeStampString:timeStampStr];
        SingleLineLyrics *singleLineObj=[SingleLineLyrics new];
        singleLineObj.startTime=startTime;
        singleLineObj.lyricText=lyricLineStr;
        [_lyricsLinesArray addObject:singleLineObj];
                                 
    }
}
-(NSUInteger)milliSecondsFromTimeStampString:(NSString *)timeStampStr
{
    const char *str=[timeStampStr cStringUsingEncoding:NSUTF8StringEncoding];
    int min,sec,per_sec;
    sscanf(str,"%d:%d.%d",&min,&sec,&per_sec);
    NSUInteger milliSeconds=min*60*1000+sec*1000+per_sec*10;
    return milliSeconds;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)letkaraokeClicked:(id)sender
{
    [_timer invalidate];
    NSData *data=[NSData dataWithContentsOfFile:_lyricsFilePath];
    [self parseWholeLyricsWithData:data];
    _timePasted =0;
    _timer=[NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(更新歌词到界面) userInfo:nil repeats:YES];
}


-(void)更新歌词到界面
{
    _timePasted+=0.1*1000;
    NSPredicate *predicate=[NSPredicate predicateWithFormat:@"startTime>=%lu",_timePasted];
    NSArray *resultArray=[_lyricsLinesArray filteredArrayUsingPredicate:predicate];
    SingleLineLyrics *currentLyricObj=(resultArray&&resultArray.count>0)?resultArray[0]:nil;
    _lyricLabel.text=currentLyricObj.lyricText;
}
@end
















