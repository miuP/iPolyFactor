//
//  SSViewController.m
//  iPolyFactor
//
//  Created by IWAMA Yusuke on 6/19/13.
//  Copyright (c) 2013 SoySrc. All rights reserved.
//

#import "SSViewController.h"

#define NUMBER_OF_KEYS 16

@interface SSViewController ()

@end

@implementation SSViewController {
	UIView		*keyboardView;
	NSArray		*buttons;
	
	SSPolyFactorQuiz		*currentQuiz;
	
	UIView		*monitorView;
	UIWebView	*mathMLView;
	UILabel		*markLabel;
	UISlider	*buttonMarginSlider;
	UISwitch	*lefthandedSwitch;
	BOOL		leftHanded;
	UILabel		*resultLabel;
	UIButton	*configButton;
	BOOL		showingConfig;
	
	NSUInteger	correctCt, totalCt;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	correctCt	= [userDefaults integerForKey:@"Correct Count"];
	totalCt		= [userDefaults integerForKey:@"Total Count"];
	
	self.view.multipleTouchEnabled = NO;
	self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.18 blue:0.0 alpha:1.0];
	// Do any additional setup after loading the view, typically from a nib.
	CGSize appWinSz	= CGSizeMake([[UIScreen mainScreen] bounds].size.height, // for landscape orientation.
								 [[UIScreen mainScreen] bounds].size.width);
	
	UILabel *secretLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 0.0, appWinSz.width - 20.0, appWinSz.height)];
	[self.view addSubview:secretLabel];
	secretLabel.backgroundColor = [UIColor clearColor];
	secretLabel.textColor = [UIColor whiteColor];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		secretLabel.font = [UIFont fontWithName:@"Chalkduster" size:48.0];
	} else {
		secretLabel.font = [UIFont fontWithName:@"Chalkduster" size:18.0];
	}
	secretLabel.numberOfLines = 0;
	secretLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
	secretLabel.textAlignment = NSTextAlignmentCenter;
	secretLabel.alpha = 0.84;
	secretLabel.text = @"A human being is a part of a whole, called by us universe, a part limited in time and space. He experiences himself, his thoughts and feelings as something separated from the rest... a kind of optical delusion of his consciousness. This delusion is a kind of prison for us, restricting us to our personal desires and to affection for a few persons nearest to us. Our task must be to free ourselves from this prison by widening our circle of compassion to embrace all living creatures and the whole of nature in its beauty.";
	
	// Setup keyboard view.
	keyboardView = [[UIView alloc] initWithFrame:CGRectMake(appWinSz.width * 6.0 / 11.0, 0.0, appWinSz.width * 5.0 / 11.0, appWinSz.height)];
	[self.view addSubview:keyboardView];
	keyboardView.backgroundColor = [UIColor colorWithWhite:0.7 alpha:1.0];
	
	UIButton *button[NUMBER_OF_KEYS];
	for (int i = 0; i < NUMBER_OF_KEYS; i++) {
		button[i] = [UIButton buttonWithType:UIButtonTypeRoundedRect];
		[keyboardView addSubview:button[i]];
		button[i].exclusiveTouch = YES;
		button[i].tintColor = [UIColor colorWithWhite:1.0 alpha:1.0];
		button[i].backgroundColor = [UIColor colorWithWhite:0.0 alpha:1.0];
		button[i].layer.borderWidth = 1.0;
		button[i].layer.borderColor = [keyboardView.backgroundColor CGColor];
		button[12].backgroundColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
		button[13].backgroundColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
		button[14].backgroundColor = [UIColor colorWithRed:0.8 green:0.0 blue:0.0 alpha:1.0];
		if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
			button[i].titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:100.0];
		} else {
			button[i].titleLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:42.0];
		}
		button[i].contentEdgeInsets = UIEdgeInsetsMake(0.0, 14.0, 0.0, 14.0);
		button[i].titleLabel.adjustsFontSizeToFitWidth = YES;
		[button[i] addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchDown];
	}
	buttons = [NSArray arrayWithObjects:button count:NUMBER_OF_KEYS];
	[self renameButtonTitle];
	
	// Setup problem view
	monitorView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, appWinSz.width * 6.0 / 11.0, appWinSz.height)];
	[self.view addSubview:monitorView];
	
	mathMLView = [[UIWebView alloc] initWithFrame:monitorView.frame];
	[monitorView addSubview:mathMLView];
//	mathMLView.scalesPageToFit = YES;
	mathMLView.userInteractionEnabled = NO;
	
	// For quiz
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateMathMLView) name:SSPolyFactorQuizDidUpdateExpressionNotification object:nil];
	srand(time(NULL));

	// Config ==================================================================
	configButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
	configButton.tintColor = [UIColor whiteColor];
	[monitorView addSubview:configButton];
	configButton.frame = CGRectMake(monitorView.frame.size.width / 2.0 - 12.0, 10.0, 24.0, 24.0);
	[configButton addTarget:self action:@selector(configButtonAction) forControlEvents:UIControlEventTouchUpInside];
	
	buttonMarginSlider = [[UISlider alloc] initWithFrame:CGRectMake(10.0, 44.0, mathMLView.frame.size.width - 20.0, 44.0)];
	[monitorView addSubview:buttonMarginSlider];
	[buttonMarginSlider addTarget:self action:@selector(resizeButtons:) forControlEvents:UIControlEventValueChanged];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		buttonMarginSlider.maximumValue = 60.0;
		buttonMarginSlider.minimumValue = 0.0;
	} else {
		buttonMarginSlider.maximumValue = 20.0;
		buttonMarginSlider.minimumValue = 0.0;
	}
	buttonMarginSlider.value = [userDefaults doubleForKey:@"button margin"];
	[self resizeButtons:buttonMarginSlider];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		lefthandedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(mathMLView.frame.size.width / 2.0 + 44.0, 10.0, 80.0, 44.0)];
	} else {
		lefthandedSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(mathMLView.frame.size.width / 2.0 + 44.0, 10.0, 80.0, 44.0)];
	}
	[monitorView addSubview:lefthandedSwitch];
	[lefthandedSwitch addTarget:self action:@selector(changeHandedness:) forControlEvents:UIControlEventValueChanged];
	leftHanded = [userDefaults boolForKey:@"left-handed"];
	lefthandedSwitch.on = leftHanded;
	[self changeHandedness:lefthandedSwitch];
	
	showingConfig = YES;
	[self configButtonAction];
	// =========================================================================
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, appWinSz.height - 110.0, mathMLView.frame.size.width - 20.0, 100.0)];
	} else {
		resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, appWinSz.height - 54.0, mathMLView.frame.size.width - 20.0, 44.0)];
	}
	[monitorView addSubview:resultLabel];
	resultLabel.font = [UIFont fontWithName:@"ArialRoundedMTBold" size:32.0];
	resultLabel.backgroundColor = [UIColor clearColor];
	resultLabel.textColor = [UIColor whiteColor];
	resultLabel.adjustsFontSizeToFitWidth = YES;
	resultLabel.textAlignment = NSTextAlignmentCenter;
	
	markLabel = [[UILabel alloc] initWithFrame:mathMLView.frame];
	[monitorView addSubview:markLabel];
	markLabel.backgroundColor = [UIColor clearColor];
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		markLabel.font = [UIFont fontWithName:@"Futura-Medium" size:500.0];
	} else {
		markLabel.font = [UIFont fontWithName:@"Futura-Medium" size:300.0];
	}
	markLabel.adjustsFontSizeToFitWidth = YES;
	markLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.5];
	markLabel.textAlignment = NSTextAlignmentCenter;
	
	[self updateResultLabel];
	[self quiz];
}

- (void)configButtonAction
{
	if (showingConfig) {
		buttonMarginSlider.hidden = YES;
		lefthandedSwitch.hidden = YES;
		showingConfig = NO;
	} else {
		buttonMarginSlider.hidden = NO;
		lefthandedSwitch.hidden = NO;
		showingConfig = YES;
	}
}

- (void)changeHandedness:(id)sender
{
	[UIView animateWithDuration:1.0 animations:^{
		UISwitch *aSwitch = sender;
		if (aSwitch.on) {
			leftHanded = YES;
			keyboardView.frame = CGRectMake(0.0, 0.0, keyboardView.frame.size.width, keyboardView.frame.size.height);
			monitorView.frame = CGRectMake(keyboardView.frame.size.width, 0.0, monitorView.frame.size.width, monitorView.frame.size.height);
		} else {
			leftHanded = NO;
			monitorView.frame = CGRectMake(0.0, 0.0, monitorView.frame.size.width, monitorView.frame.size.height);
			keyboardView.frame = CGRectMake(monitorView.frame.size.width, 0.0, keyboardView.frame.size.width, keyboardView.frame.size.height);
		}
	}];
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setBool:leftHanded forKey:@"left-handed"];
}

- (void)resizeButtons:(id)sender
{
	UISlider *aSlider = sender;
	for (int i = 0; i < NUMBER_OF_KEYS; i++) {
		UIButton *aButton = buttons[i];
		aButton.frame = CGRectMake((keyboardView.frame.size.width / 3.0) * (i % 3) + aSlider.value,
								   (keyboardView.frame.size.height * (4.0 / 5.0 - (1.0 / 5.0) * (i / 3))) + aSlider.value,
								   keyboardView.frame.size.width / 3 - aSlider.value * 2,
								   keyboardView.frame.size.height / 5 - aSlider.value * 2);
	}
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setDouble:aSlider.value forKey:@"button margin"];
}

- (void)renameButtonTitle
{
	for (UIButton *aButton in buttons) {
		NSInteger index = [buttons indexOfObject:aButton];
		switch (index) {
			case 0:
			{
				[aButton setTitle:@"0" forState:UIControlStateNormal];
			}
				break;
			case 1:
			{
				[aButton setTitle:@"+" forState:UIControlStateNormal];
			}
				break;
			case 2:
			{
				[aButton setTitle:@"-" forState:UIControlStateNormal];
			}
				break;
			case 3:
			{
				[aButton setTitle:@"1" forState:UIControlStateNormal];
			}
				break;
			case 4:
			{
				[aButton setTitle:@"2" forState:UIControlStateNormal];
			}
				break;
			case 5:
			{
				[aButton setTitle:@"3" forState:UIControlStateNormal];
			}
				break;
			case 6:
			{
				[aButton setTitle:@"4" forState:UIControlStateNormal];
			}
				break;
			case 7:
			{
				[aButton setTitle:@"5" forState:UIControlStateNormal];
			}
				break;
			case 8:
			{
				[aButton setTitle:@"6" forState:UIControlStateNormal];
			}
				break;
			case 9:
			{
				[aButton setTitle:@"7" forState:UIControlStateNormal];
			}
				break;
			case 10:
			{
				[aButton setTitle:@"8" forState:UIControlStateNormal];
			}
				break;
			case 11:
			{
				[aButton setTitle:@"9" forState:UIControlStateNormal];
			}
				break;
			case 12:
			{
				[aButton setTitle:@"C" forState:UIControlStateNormal];
			}
				break;
			case 13:
			{
				[aButton setTitle:@"?" forState:UIControlStateNormal];
				[aButton setTitleColor:aButton.backgroundColor forState:UIControlStateNormal];
				aButton.userInteractionEnabled = NO;
			}
				break;
			case 14:
			{
				[aButton setTitle:@"=" forState:UIControlStateNormal];
			}
				break;
			default:
				break;
		}
	}
}

- (void)buttonAction:(id)sender
{
	NSInteger index = [buttons indexOfObject:sender];
	switch (index) {
		case 0:	// 0
			[currentQuiz updateWithInput:0];
			break;
		case 1:	// +
			[currentQuiz updateWithInput:SSPolyFactorQuizSignPlus];
			break;
		case 2:	// -
			[currentQuiz updateWithInput:SSPolyFactorQuizSignMinus];
			break;
		case 3:	// 1
			[currentQuiz updateWithInput:1];
			break;
		case 4:
			[currentQuiz updateWithInput:2];
			break;
		case 5:
			[currentQuiz updateWithInput:3];
			break;
		case 6:
			[currentQuiz updateWithInput:4];
			break;
		case 7:
			[currentQuiz updateWithInput:5];
			break;
		case 8:
			[currentQuiz updateWithInput:6];
			break;
		case 9:
			[currentQuiz updateWithInput:7];
			break;
		case 10:
			[currentQuiz updateWithInput:8];
			break;
		case 11:	// 9
			[currentQuiz updateWithInput:9];
			break;
		case 12:	// Clear
			if (currentQuiz.phase == SSPolyFactorQuizPhaseShowingResult) {
				markLabel.text = @"";
			}
			[currentQuiz rollBack];
			break;
		case 13:	// ?
			if (currentQuiz.finished == YES) { // Only the player who has tried to solve the problem can see the answer.
				[currentQuiz giveUp];
				[self updateResultLabel];
			}
			break;
		case 14:	// =
			if (currentQuiz.phase == SSPolyFactorQuizPhaseWaitingConfirmation) {
				BOOL firstAttempt = YES;
				if (currentQuiz.finished) {
					firstAttempt = NO;
				}
				if ([currentQuiz evaluate]) {
					if (firstAttempt) {
						correctCt++;
					}
					markLabel.text = @"O";
				} else {
					markLabel.text = @"×";
				}
				((UIButton *)buttons[13]).userInteractionEnabled = YES;
				[((UIButton *)buttons[13]) setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
				[self updateResultLabel];
			} else if (currentQuiz.phase == SSPolyFactorQuizPhaseShowingResult && [currentQuiz evaluate] == YES) {	// If user understand how to solve, then he can go to the next quiz.
				markLabel.text = @"";
				[self quiz];
			}
			break;
		default:
			break;
	}
}

- (void)updateResultLabel
{
	if (totalCt == 0) return;
	double percentage = (double)correctCt / totalCt;
	if (percentage >= 1.0) {
		resultLabel.textColor = [UIColor whiteColor];
	} else if (percentage >= 0.9) {
		resultLabel.textColor = [UIColor colorWithRed:0.6 green:0.6 blue:1.0 alpha:1.0]; // blue
	} else if (percentage >= 0.8) {
		resultLabel.textColor = [UIColor colorWithRed:0.6 green:1.0 blue:0.6 alpha:1.0]; // green
	} else if (percentage >= 0.7) {
		resultLabel.textColor = [UIColor colorWithRed:1.0 green:1.0 blue:0.6 alpha:1.0]; // yellow
	} else if (percentage >= 0.6) {
		resultLabel.textColor = [UIColor colorWithRed:1.0 green:0.7 blue:0.5 alpha:1.0]; // orange
	} else {
		resultLabel.textColor = [UIColor colorWithRed:1.0 green:0.0 blue:0.8 alpha:1.0]; // pink
	}
	resultLabel.text = [NSString stringWithFormat:@"%d / %d (%3.1f%%)", correctCt, totalCt, percentage * 100];
	
	NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
	[userDefaults setInteger:correctCt forKey:@"Correct Count"];
	[userDefaults setInteger:totalCt forKey:@"Total Count"];
	BOOL success = [userDefaults synchronize];
	if (success) {
		NSLog(@"User default succeeded in saveing data.");
	}
}

- (void)quiz
{
	totalCt++;
	currentQuiz = [SSPolyFactorQuiz quizWithLevel:SSPolyFactorQuizLevelBEGINNER];
	[self updateMathMLView];
	((UIButton *)buttons[13]).userInteractionEnabled = NO;
	[((UIButton *)buttons[13]) setTitleColor:((UIButton *)buttons[13]).backgroundColor forState:UIControlStateNormal];
}

- (void)updateMathMLView
{
	const NSString *header;
	(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? (header = headerForPad) : (header = headerForPhone);
	NSString *HTMLString = [NSString stringWithFormat:@"<html>%@<body>%@</body></html>", header, currentQuiz.mathMLRepresentation];
	[mathMLView loadHTMLString:HTMLString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end