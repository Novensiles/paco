//
//  Generated by the J2ObjC translator.  DO NOT EDIT!
//  source: /Users/northropo/Projects/paco/Shared/src/com/pacoapp/paco/shared/model2/Validator.java
//

#include "IOSObjectArray.h"
#include "J2ObjC_source.h"
#include "Validator.h"
#include "java/util/Collection.h"

@interface PAValidator : NSObject

@end

@implementation PAValidator

+ (const J2ObjcClassInfo *)__metadata {
  static const J2ObjcMethodInfo methods[] = {
    { "addErrorWithNSString:", "addError", "V", 0x401, NULL, NULL },
    { "isNotNullAndNonEmptyStringWithNSString:withNSString:", "isNotNullAndNonEmptyString", "Z", 0x401, NULL, NULL },
    { "isNotNullAndNonEmptyCollectionWithJavaUtilCollection:withNSString:", "isNotNullAndNonEmptyCollection", "Z", 0x401, NULL, NULL },
    { "isValidEmailWithNSString:withNSString:", "isValidEmail", "Z", 0x401, NULL, NULL },
    { "isValidCollectionOfEmailAddressesWithJavaUtilCollection:withNSString:", "isValidCollectionOfEmailAddresses", "Z", 0x401, NULL, "(Ljava/util/Collection<Ljava/lang/String;>;Ljava/lang/String;)Z" },
    { "isNotNullCollectionWithJavaUtilCollection:withNSString:", "isNotNullCollection", "Z", 0x401, NULL, NULL },
    { "isValidDateStringWithNSString:withNSString:", "isValidDateString", "Z", 0x401, NULL, NULL },
    { "isNotNullWithId:withNSString:", "isNotNull", "Z", 0x401, NULL, NULL },
    { "isValidJavascriptWithNSString:withNSString:", "isValidJavascript", "Z", 0x401, NULL, NULL },
    { "isValidHtmlOrJavascriptWithNSString:withNSString:", "isValidHtmlOrJavascript", "Z", 0x401, NULL, NULL },
    { "isTrueWithBoolean:withNSString:", "isTrue", "Z", 0x401, NULL, NULL },
    { "isNotNullAndNonEmptyArrayWithNSStringArray:withNSString:", "isNotNullAndNonEmptyArray", "Z", 0x401, NULL, NULL },
    { "isValidConditionalExpressionWithNSString:withNSString:", "isValidConditionalExpression", "Z", 0x401, NULL, NULL },
  };
  static const J2ObjcFieldInfo fields[] = {
    { "MANDATORY", "MANDATORY", 0x19, "I", NULL, NULL, .constantValue.asInt = PAValidator_MANDATORY },
    { "OPTIONAL", "OPTIONAL", 0x19, "I", NULL, NULL, .constantValue.asInt = PAValidator_OPTIONAL },
  };
  static const J2ObjcClassInfo _PAValidator = { 2, "Validator", "com.pacoapp.paco.shared.model2", NULL, 0x609, 13, methods, 2, fields, 0, NULL, 0, NULL, NULL, NULL };
  return &_PAValidator;
}

@end

J2OBJC_INTERFACE_TYPE_LITERAL_SOURCE(PAValidator)