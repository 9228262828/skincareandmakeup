//
//  SkinCareSurveyForm.h
//  PerfectLib
//
//  Created by PX Chen on 2020/5/19.
//  Copyright © 2020 Perfect Corp. All rights reserved.
//

#import <PerfectLibRecommendationHandler/PerfectLibRecommendationHandler.h>

NS_ASSUME_NONNULL_BEGIN

@class SkinCareSurveyFormQuestion;
@class SkinCareSurveyFormOption;

/**
The class to describe the structure of survey form.
*/
@interface SkinCareSurveyForm : PFSurveyForm

/// survey form's title
@property (strong, readonly) NSString *title;
/// the title for previous question button.
@property (strong, readonly) NSString *previousButtonText;
/// the title for next question button
@property (strong, readonly) NSString *nextButtonText;
/// the title for done button
@property (strong, readonly) NSString *doneButtonText;
/// the question text
@property (strong, readonly) NSString *questionText;
/// the questions included by this survey form
@property (strong, readonly) NSArray<SkinCareSurveyFormQuestion *> *questions;
@end

/**
The class to represent a question from `SkinCareSurveyForm`.
*/
@interface SkinCareSurveyFormQuestion : NSObject
/// the type of the question.
@property (assign, readonly) SurveyQuestionType type;
/// the description of this question
@property (strong, readonly) NSString *title;
/// the detail description of this question
@property (strong, readonly) NSString *detailDescription;
/// indicate that if this question can be skipped.
@property (assign, readonly) BOOL isRequired;
/// the options included by this question.
@property (strong, readonly) NSArray<SkinCareSurveyFormOption *> *options;
@end

/**
The class to represent an option from `SkinCareSurveyFormQuestion`.
*/
@interface SkinCareSurveyFormOption : NSObject
/// the option's description.
@property (strong, readonly) NSString *title;

/// the option id
@property (strong, readonly) NSString *optionId;
@end

NS_ASSUME_NONNULL_END
