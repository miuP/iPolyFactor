//
//  SSPolyFactorQuiz.m
//  iPolyFactor
//
//  Created by Yusuke IWAMA on 6/18/13.
//  Copyright (c) 2013 SoySrc. All rights reserved.
//

#import "SSPolyFactorQuiz.h"

const NSString *headerForPad =
@"<head>"
"<style type=\"text/css\">"
"<!--"
"body"
"{"
"font-size:			5.5em;"
"background-color:	#004400;"
"color:				#ffffff;"
"margin-top:		240px;"
"padding:			0px;"
"text-align:		center;"
"}"

"#main"
"{"
"margin-left:		auto;"
"margin-right:		auto;"
"text-align:		left;"
"width:				650px;"
"}"
"-->"
"</style>"
"</head>";

const NSString *headerForPhone =
@"<head>"
"<style type=\"text/css\">"
"<!--"
"body"
"{"
"font-size:			3.0em;"
"background-color:	#004400;"
"color:				#ffffff;"
"margin-top:		80px;"
"padding:			0px;"
"text-align:		center;"
"}"

"#main"
"{"
"margin-left:		auto;"
"margin-right:		auto;"
"text-align:		left;"
"}"
"-->"
"</style>"
"</head>";


NSString *SSPolyFactorQuizDidUpdateExpressionNotification = @"SSPolyFactorQuizDidUpdateExpressionNotification";

@implementation SSPolyFactorQuiz {
	NSString *x2String, *xString, *lMrow, *lParenthesis1, *firstX, *rParenthesis1, *lParenthesis2, *rParenthesis2, *rMrow;
	NSString *signAString, *absAString, *signBString, *absBString, *signCString, *absCString;
	NSString *signKString, *absKString, *signPString, *absPString, *signQString, *absQString, *signRString, *absRString, *signSString, *absSString;
	NSArray	*program;	// Program for the specific level.
	NSInteger phaseIndex;
	BOOL gaveUp;
}

@synthesize a, b, c, k, p, q, r, s;
@synthesize signK, absK, signP, absP, signQ, absQ, signR, absR, signS, absS;
@synthesize phase;
@synthesize level;
@synthesize mathMLRepresentation;
@synthesize finished;

+ (SSPolyFactorQuiz *)quizWithLevel:(SSPolyFactorQuizLevel)l
{
	SSPolyFactorQuiz *aQuiz = [[self alloc] initWithLevel:l];
	return  aQuiz;
}

- (id)initWithLevel:(SSPolyFactorQuizLevel)l
{
	level = l;
	lMrow		= @"<mrow>";
	rMrow		= @"</mrow>";
	x2String	= @"<msup><mi>x</mi><mn>2</mn></msup>";
	xString		= @"<mi>x</mi>";
	lParenthesis1	= @"<mo>(</mo>";
	rParenthesis1	= @"<mo>)</mo>";
	lParenthesis2	= @"<mo>(</mo>";
	rParenthesis2	= @"<mo>)</mo>";
	firstX			= @"<mi>x</mi>";
	switch (level) {	// 今後、中級の問題を生成する際に使用する。
		{case SSPolyFactorQuizLevelBEGINNER:
			k		= 1, signK = 1, signKString = @"";
			p		= 1, signP = 1, signPString = @"";
			r		= 1, signR = 1, signRString = @"";
			absK	= 1, absKString = @"";
			absP	= 1, absPString = @"";
			absR	= 1, absRString = @"";
			while (q == 0 && s == 0) { // previous -> q == s
				q = (int)(19.0 * rand() / (RAND_MAX + 1.0)) - 9;
				s = (int)(19.0 * rand() / (RAND_MAX + 1.0)) - 9;
				if (q < s) {
					int temp = q;
					q = s;
					s = temp;
				}
			}
			if (s == 0) { // prevent x+a(x+0) form when give up.
				int temp = q;
				q = s;
				s = temp;
			}
			NSArray *programForBeginner = @[[NSNumber numberWithInt:SSPolyFactorQuizPhaseWaitingFirstConstSign],
								   [NSNumber numberWithInt:SSPolyFactorQuizPhaseWaitingFirstConstAbs],
								   [NSNumber numberWithInt:SSPolyFactorQuizPhaseWaitingSecondConstSign],
								   [NSNumber numberWithInt:SSPolyFactorQuizPhaseWaitingSecondConstAbs],
								   [NSNumber numberWithInt:SSPolyFactorQuizPhaseWaitingConfirmation],
								   [NSNumber numberWithInt:SSPolyFactorQuizPhaseShowingResult]
								   ];
			program = programForBeginner;
			phase = [program[phaseIndex] intValue];
			break;
		}	// without braces -> strange error: "switch case is in protected scope"
		default:
			break;
	}
	// the formulas to calc coefficients of polynomial is common through levels.
	a = k * p * r;
	(a > 0) ? (signAString = @"") : (signAString = @"<mo>-</mo>");
	(abs(a) == 1) ? (absAString = @"") : (absAString = [NSString stringWithFormat:@"<mn>%d</mn>", abs(a)]);
	b = k * (p * s + q * r);
	if (b == 0) {
		signBString = @"";
		absBString	= @"";
		xString		= @"";
	} else {
		(b > 0) ? (signBString = @"<mo>+</mo>") : (signBString = @"<mo>-</mo>");
		(abs(b) == 1) ? (absBString = @"") : (absBString = [NSString stringWithFormat:@"<mn>%d</mn>", abs(b)]);
	}
	c = k * q * s;
	if (c == 0 || (p == r && q == s)) {
		signQString = @"";
		absQString	= @"";
		lParenthesis1 = @"";
		rParenthesis1 = @"";
		if (c == 0) {
			signCString = @"";
			absCString	= @"";
			signP = 1, absP = 1, signQ = 1, absQ = 0;
		} else {
			lMrow = @"<msup><mrow>";
			rMrow = @"</mrow><mn>2</mn></msup>";
			(c > 0) ? (signCString = @"<mo>+</mo>") : (signCString = @"<mo>-</mo>");
			absCString	= [NSString stringWithFormat:@"<mn>%d</mn>", abs(c)];
			absK	= abs(k);
			signK	= k / absK;
			absP	= abs(p);
			signP	= p / absP;
			absQ	= abs(q);
			signQ	= q / absQ;
			firstX	= @"";
		}
		switch (level) {
			case SSPolyFactorQuizLevelBEGINNER:
				phase = SSPolyFactorQuizPhaseWaitingSecondConstSign;
				phaseIndex = [program indexOfObject:[NSNumber numberWithInt:phase]];
				break;
			default:
				break;
		}
	} else {
		(c > 0) ? (signCString = @"<mo>+</mo>") : (signCString = @"<mo>-</mo>");
		absCString = [NSString stringWithFormat:@"<mn>%d</mn>", abs(c)];
	}

	[self updateMathMLRepresentation];
	
	return self;
}

- (void)updateMathMLRepresentation
{
	NSString *tempString;
	tempString = [NSString stringWithFormat:
				  @"<math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
				  "<mrow>%@%@%@%@%@%@%@%@</mrow>"
				  "</math><br /><br /><math xmlns=\"http://www.w3.org/1998/Math/MathML\">"
				  "<mo>=</mo>", signAString, absAString, x2String, signBString, absBString, xString, signCString, absCString];
	switch (phase) {
		case SSPolyFactorQuizPhaseWaitingCommonFactorSign:
			break;
		case SSPolyFactorQuizPhaseWaitingCommonFactorAbs:
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@</mrow></math>", signKString];
			break;
		case SSPolyFactorQuizPhaseWaitingFirstCoeffSign:
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@%@</mrow></math>", signKString, absKString];
			break;
		case SSPolyFactorQuizPhaseWaitingFirstCoeffAbs:
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@%@%@%@</mrow></math>", signAString, absKString, lParenthesis1, signPString];
			break;
		case SSPolyFactorQuizPhaseWaitingFirstConstSign:	// beginners start here
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@%@%@%@%@<mi>x</mi></mrow></math>", signKString, absKString, lParenthesis1, signPString, absPString];
			break;
		case SSPolyFactorQuizPhaseWaitingFirstConstAbs:
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@%@%@%@%@<mi>x</mi>%@</mrow></math>", signAString, absKString, lParenthesis1, signPString, absPString, signQString];
			break;
		case SSPolyFactorQuizPhaseWaitingSecondCoeffSign:
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@%@%@%@%@<mi>x</mi>%@%@%@%@</mrow></math>", signAString, absKString, lParenthesis1, signPString, absPString, signQString, absQString, rParenthesis1, lParenthesis2];
			break;
		case SSPolyFactorQuizPhaseWaitingSecondCoeffAbs:
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@%@%@%@%@<mi>x</mi>%@%@%@%@%@</mrow></math>", signAString, absKString, lParenthesis1, signPString, absPString, signQString, absQString, rParenthesis1, lParenthesis2, signRString];
			break;
		case SSPolyFactorQuizPhaseWaitingSecondConstSign:
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@%@%@%@%@%@%@%@%@%@%@%@<mi>x</mi></mrow></math>", signAString, absKString, lParenthesis1, signPString, absPString, firstX, signQString, absQString, rParenthesis1, lParenthesis2, signRString, absRString];
			break;
		case SSPolyFactorQuizPhaseWaitingSecondConstAbs:
			tempString = [tempString stringByAppendingFormat:@"<mrow>%@%@%@%@%@%@%@%@%@%@%@%@<mi>x</mi>%@</mrow></math>", signAString, absKString, lParenthesis1, signPString, absPString, firstX, signQString, absQString, rParenthesis1, lParenthesis2, signRString, absRString, signSString];
			break;
		case SSPolyFactorQuizPhaseWaitingConfirmation:{
			NSString *str = @"";
			if ((p == r && q == s)) {
				str = @"<msup>";
			}
			tempString = [tempString stringByAppendingFormat:@"%@<mrow>%@%@%@%@%@%@%@%@%@%@%@%@<mi>x</mi>%@%@%@%@</math>", str, signAString, absKString, lParenthesis1, signPString, firstX, absPString, signQString, absQString, rParenthesis1, lParenthesis2, signRString, absRString, signSString, absSString, rParenthesis2, rMrow];
			break;}
		case SSPolyFactorQuizPhaseShowingResult:{
			NSString *str = @"";
			if ((p == r && q == s)) {
				str = @"<msup>";
			}
			if (gaveUp) {
				str = @"<msup mathcolor=\"#FF44EE\">";
				tempString = [tempString stringByAppendingFormat:@"%@<mrow mathcolor=\"#FF44EE\">%@%@%@%@%@%@%@%@%@%@%@%@<mi>x</mi>%@%@%@%@</math>", str, signAString, absKString, lParenthesis1, signPString, absPString, firstX, signQString, absQString, rParenthesis1, lParenthesis2, signRString, absRString, signSString, absSString, rParenthesis2, rMrow];
			} else {
				tempString = [tempString stringByAppendingFormat:@"%@<mrow>%@%@%@%@%@%@%@%@%@%@%@%@<mi>x</mi>%@%@%@%@</math>", str, signAString, absKString, lParenthesis1, signPString, absPString, firstX, signQString, absQString, rParenthesis1, lParenthesis2, signRString, absRString, signSString, absSString, rParenthesis2, rMrow];
			}}
			break;
		default:
			break;
	}
	mathMLRepresentation = tempString;
	NSLog(@"MathML source: %@", mathMLRepresentation);
}

- (void)updateWithInput:(NSInteger)input
{
	switch (phase) {
		case SSPolyFactorQuizPhaseWaitingCommonFactorSign:
			if (input == SSPolyFactorQuizSignPlus) {
				signK = 1;
				signKString = @"";
				[self updateMathMLRepresentation];
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			} else if (input == SSPolyFactorQuizSignMinus) {
				signK = -1;
				signKString = @"<mo>-</mo>";
				[self updateMathMLRepresentation];
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingCommonFactorAbs:
			if (0 <= input && input <= 9) {
				absK = input;
				[self updateMathMLRepresentation];
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingFirstCoeffSign:
			if (input == SSPolyFactorQuizSignPlus) {
				signP = 1;
				signPString = @"";
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			} else if (input == SSPolyFactorQuizSignMinus) {
				signP = -1;
				signPString = @"<mo>-</mo>";
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingFirstCoeffAbs:
			if (0 <= input && input <= 9) {
				absP = input;
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingFirstConstSign:	// beginner starts here
			if (input == SSPolyFactorQuizSignPlus) {
				signQ = 1;
				signQString = @"<mo>+</mo>";
			} else if (input == SSPolyFactorQuizSignMinus) {
				signQ = -1;
				signQString = @"<mo>-</mo>";
			}
			if (input == SSPolyFactorQuizSignPlus || input == SSPolyFactorQuizSignMinus) {
				phase = [program[++phaseIndex] intValue];
				[self updateMathMLRepresentation];
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingFirstConstAbs:
			if (0 <= input && input <= 9) {
				absQ = input;
				absQString = [NSString stringWithFormat:@"<mn>%d</mn>", input];
				switch (level) {
					case SSPolyFactorQuizLevelBEGINNER:
						phase = [program[++phaseIndex] intValue];
						break;
					default:
						break;
				}
				[self updateMathMLRepresentation];
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingSecondCoeffSign:
			if (input == SSPolyFactorQuizSignPlus) {
				signR = 1;
				signRString = @"";
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			} else if (input == SSPolyFactorQuizSignMinus) {
				signR = -1;
				signRString = @"<mo>-</mo>";
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingSecondCoeffAbs:
			if (0 <= input && input <= 9) {
				absR = input;
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingSecondConstSign:
			if (input == SSPolyFactorQuizSignPlus) {
				signS = 1;
				signSString = @"<mo>+</mo>";
			} else if (input == SSPolyFactorQuizSignMinus) {
				signS = -1;
				signSString = @"<mo>-</mo>";
			}
			if (input == SSPolyFactorQuizSignPlus || input == SSPolyFactorQuizSignMinus) {
				phase = [program[++phaseIndex] intValue];
				[self updateMathMLRepresentation];
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		case SSPolyFactorQuizPhaseWaitingSecondConstAbs:
			if (0 <= input && input <= 9) {
				absS = input;
				absSString = [NSString stringWithFormat:@"<mn>%d</mn>", input];
				phase = [program[++phaseIndex] intValue];
				[self updateMathMLRepresentation];
				[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
			}
			break;
		default:
			break;
	}
}

- (void)rollBack
{
	if (phaseIndex != 0) {
		if (c == 0 || (p == r && q == s)) {
			if (phase == SSPolyFactorQuizPhaseWaitingSecondConstSign) {	// starting point.
				return;
			}
		}
		phase = [program[--phaseIndex] intValue];
		[self updateMathMLRepresentation];
		[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
	}
}

- (void)giveUp
{
	gaveUp = YES;
	(k > 0) ? (signKString = @"") : (signKString = @"<mo>-</mo>");
	(p > 0) ? (signPString = @"") : (signPString = @"<mo>-</mo>");
	if (!(c == 0 || (p == r && q == s))) {
		(q > 0) ? (signQString = @"<mo>+</mo>") : (signQString = @"<mo>-</mo>");
		absQString = [NSString stringWithFormat:@"<mn>%d</mn>", abs(q)];
	}
	(r > 0) ? (signRString = @"") : (signRString = @"<mo>-</mo>");
	(s > 0) ? (signSString = @"<mo>+</mo>") : (signSString = @"<mo>-</mo>");
	(abs(k) == 1) ? absKString = @"" : (absKString = [NSString stringWithFormat:@"<mn>%d</mn>", abs(k)]);
	(abs(p) == 1) ? absKString = @"" : (absPString = [NSString stringWithFormat:@"<mn>%d</mn>", abs(p)]);
	(abs(r) == 1) ? absKString = @"" : (absRString = [NSString stringWithFormat:@"<mn>%d</mn>", abs(r)]);
	absSString = [NSString stringWithFormat:@"<mn>%d</mn>", abs(s)];
	absK	= abs(k);
	signK	= k / absK;
	absP	= abs(p);
	signP	= p / absP;
	absQ	= abs(q);
	(q == 0) ? (signQ = 1) : (signQ	= q / absQ);
	absR	= abs(r);
	signR	= r / absR;
	absS	= abs(s);
	signS	= s / absS;
	phase = SSPolyFactorQuizPhaseShowingResult;
	phaseIndex = [program indexOfObject:[NSNumber numberWithInt:phase]];
	[self updateMathMLRepresentation];
	[[NSNotificationCenter defaultCenter] postNotificationName:SSPolyFactorQuizDidUpdateExpressionNotification object:self];
	NSLog(@"a=%d, b=%d, c=%d, absK=%d, signK=%d, signP=%d, absP=%d, signQ=%d, absQ=%d, signR=%d, absR=%d, signS=%d, absS=%d", a, b, c, absK, signK, signP, absP, signQ, absQ, signR, absR, signS, absS);
}

- (BOOL)evaluate
{
	finished = YES;
	if (SSPolyFactorQuizPhaseWaitingConfirmation) {
		phase = SSPolyFactorQuizPhaseShowingResult;
		if ((signK * absK == k) && ((signP * absP == p && signQ * absQ == q && signR * absR == r && signS * absS == s)
									|| (signP * absP == r && signQ * absQ == s && signR * absR == p && signS * absS == q))) {
				return YES;
			} else {
				return NO;
			}
	}
}

@end
