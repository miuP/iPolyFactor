//
//  SSPolyFactorQuiz.h
//  iPolyFactor
//
//  Created by Yusuke IWAMA on 6/18/13.
//  Copyright (c) 2013 SoySrc. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum SSPolyFactorQuizLevel {
	SSPolyFactorQuizLevelBEGINNER,
	SSPolyFactorQuizLevelINTERMEDIATE,
	SSPolyFactorQuizLevelADVANCED
} SSPolyFactorQuizLevel;

typedef enum SSPolyFactorQuizSign {
	SSPolyFactorQuizSignPlus	= 10000,
	SSPolyFactorQuizSignMinus	= -10000
} SSPolyFactorQuizSign;

typedef enum SSPolyFactorQuizPhase {	// ax^2 + bx + c = k(px + q)(rx + s)
	SSPolyFactorQuizPhaseWaitingCommonFactorSign	= 0,	// waiting sign of k
	SSPolyFactorQuizPhaseWaitingCommonFactorAbs,	// waiting abs k
	SSPolyFactorQuizPhaseWaitingFirstCoeffSign,	// waiting sign of p
	SSPolyFactorQuizPhaseWaitingFirstCoeffAbs,		// waiting abs p
	SSPolyFactorQuizPhaseWaitingFirstConstSign,	// waiting sign of q
	SSPolyFactorQuizPhaseWaitingFirstConstAbs,		// waiting abs q
	SSPolyFactorQuizPhaseWaitingSecondCoeffSign,	// waiting sign of r
	SSPolyFactorQuizPhaseWaitingSecondCoeffAbs,	// waiting abs r
	SSPolyFactorQuizPhaseWaitingSecondConstSign,	// waiting sign of s
	SSPolyFactorQuizPhaseWaitingSecondConstAbs,	// waiting abs s
	SSPolyFactorQuizPhaseWaitingConfirmation,		// waiting for user's confirmation
	SSPolyFactorQuizPhaseShowingResult				// showing result
} SSPolyFactorQuizPhase;

FOUNDATION_EXPORT const NSString *headerForPad;	// HTML header
FOUNDATION_EXPORT const NSString *headerForPhone;	// HTML header
FOUNDATION_EXPORT NSString *SSPolyFactorQuizDidUpdateExpressionNotification;	// notification for redrawing mathML view.
// VCはこの通知でQuizから入力状況を読み取り画面をアップデートしなければならない。

@interface SSPolyFactorQuiz : NSObject

@property (readonly)	NSInteger a, b, c, k, p, q, r, s;	// ax^2 + bx + c = k(px + q)(rx + s)
@property (readwrite)	NSInteger signK, absK, signP, absP, signQ, absQ, signR, absR, signS, absS;	// user's answer
@property (readonly)	SSPolyFactorQuizPhase phase;
@property (readonly)	SSPolyFactorQuizLevel level;
@property (readonly)	NSString *mathMLRepresentation;
@property (readonly)	BOOL finished;

/* Phase rule ==================================================================
 0: waiting for first sign
 1: waiting for first number
 2: waiting for second sign
 3: waiting for second sign
 4: waiting for confirmation
 5: displaying result
============================================================================= */

+ (SSPolyFactorQuiz *)quizWithLevel:(SSPolyFactorQuizLevel)l;	// create new quiz.
- (void)updateWithInput:(NSInteger)input;	// update with user's input.
- (void)rollBack;
- (void)giveUp;
- (BOOL)evaluate;			// return true for correct answer.

@end