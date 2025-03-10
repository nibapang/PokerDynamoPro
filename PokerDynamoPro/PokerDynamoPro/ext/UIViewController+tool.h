//
//  UIViewController+tool.h
//  PokerDynamoPro
//
//  Created by jin fu on 2025/3/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger, WavesVerseType) {
    WavesVerseTypePortrait = 0,
    WavesVerseTypeLandRight = 1,
    WavesVerseTypeLandLeft = 2,
    WavesVerseTypeLandscape = 3,
    WavesVerseTypeAll = 4
};
@interface UIViewController (tool)

- (void)pokerShowAlertWithTitle:(NSString *)title message:(NSString *)message;

- (void)pokerSetNavigationBarTransparent;

- (NSDictionary *)getAFDic;
- (void)saveAFStringId:(NSString *)recordID;

- (NSString *)getAFIDStr;
- (NSNumber *)getNumber;
- (NSNumber *)getAFString;

- (NSNumber *)getStatus;
- (void)saveStatus:(NSNumber *)status;
- (NSString *)getad;

- (void)wavesShowECHOData;

- (NSArray *)adParams;

- (void)pokerPostLog:(NSString *)eventName;
- (void)pokerPostLogWhtDic:(NSDictionary *)dic;

@end

NS_ASSUME_NONNULL_END
