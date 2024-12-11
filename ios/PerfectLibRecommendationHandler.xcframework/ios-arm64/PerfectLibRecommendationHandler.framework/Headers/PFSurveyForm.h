//
//  SurveyForm.h
//  PerfectLib
//
//  Created by I Lin on 2020/5/12.
//  Copyright © 2020 Perfect Corp. All rights reserved.
//
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
Types enumeration for survey form questions`.
*/
typedef NS_ENUM(NSInteger, SurveyQuestionType) {
    /// The question with multiple answers.
    SurveyQuestionTypeCheckBox,
    /// the question only has one answer.
    SurveyQuestionTypeMultipleChoice
};

/// This is a base class, please use the derived classes.
@interface PFSurveyForm : NSObject

@end

NS_ASSUME_NONNULL_END
