//
//  GTTrackerNotifications.h
//  Snuffy
//
//  Created by Michael Harrison on 4/2/14.
//
//

/**
 *  UserInfo Keys for all GTTrackerNotification's
 */
extern NSString *const GTTrackerNotificationUserInfoLanguageKey;
extern NSString *const GTTrackerNotificationUserInfoPackageKey;
extern NSString *const GTTrackerNotificationUserInfoVersionKey;

/**
 *  Notification name for Opening a resource
 */
extern NSString *const GTTrackerNotificationResourceDidOpen;

/**
 *  Notification name for Sharing a resource
 */
extern NSString *const GTTrackerNotificationUserDidShareResource;

/**
 *  Notification name for Everystudent search
 */
extern NSString *const GTTrackerNotificationEverystudentDidSearch;

/**
 *  UserInfo Key for Evreystudent search term
 */
extern NSString *const GTTrackerNotificationEverystudentDidSearchUserInfoSearchTerm;

/**
 *  Notification name for opening an Everystudent Article
 */
extern NSString *const GTTrackerNotificationEverystudentDidOpenArticle;

/**
 *  UserInfo Key for Everystudent Article code for the open article notification.
 */
extern NSString *const GTTrackerNotificationEverystudentDidOpenArticleUserInfoArticleName;
