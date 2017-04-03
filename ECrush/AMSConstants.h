//
//  AMSConstants.h
//  ECrush
//
//  Created by Engel Alipio on 8/18/14.
//  Copyright (c) 2017 Agile Mobile Solutions. All rights reserved.
//

#define kVungleId @"5758444852886a1e390000fd"

#define kHighScoreLeaderboardCategory @"ams.com.ECrush.HighScores"
#define kMoveSaverLeaderboardCategory @"ams.com.ECrush.MoveSaver"
#define kComboMultiplierLeaderboardCategory @"ams.com.ECrush.ComboMultiplier"

#define kBestOfTheBestAchievementCategory @"ams.com.BestotBest"
#define kSavedByHairAchievementCategory @"ams.com.SavedbyHair"

#define kLastTouchedThreshold 30

enum {
    GKErrorUnknown = 1,
    GKErrorCancelled = 2,
    GKErrorCommunicationsFailure = 3,
    GKErrorUserDenied = 4,
    GKErrorInvalidCredentials = 5,
    GKErrorNotAuthenticated = 6,
    GKErrorAuthenticationInProgress = 7,
    GKErrorInvalidPlayer = 8,
    GKErrorScoreNotSet = 9,
    GKErrorParentalControlsBlocked = 10,
    GKErrorPlayerStatusExceedsMaximumLength = 11,
    GKErrorPlayerStatusInvalid = 12,
    GKErrorMatchRequestInvalid = 13,
    GKErrorUnderage = 14,
    GKErrorGameUnrecognized = 15,
    GKErrorNotSupported = 16,
    GKErrorInvalidParameter = 17,
    GKErrorUnexpectedConnection = 18,
    GKErrorChallengeInvalid = 19,
    GKErrorTurnBasedMatchDataTooLarge = 20,
    GKErrorTurnBasedTooManySessions = 21,
    GKErrorTurnBasedInvalidParticipant = 22,
    GKErrorTurnBasedInvalidTurn = 23,
    GKErrorTurnBasedInvalidState = 24,
    GKErrorInvitationsDisabled = 26,
};
typedef NSInteger GKErrorCode;
