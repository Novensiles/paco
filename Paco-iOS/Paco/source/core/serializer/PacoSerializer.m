//
//  PacoPacoSerializer.m
//  Paco
//
//  Created by Timothy  Northrop O'Brien on 7/23/15.
//
//
//

/*
   ToDo

    - optimization = only perform matching when parent is a list
    - code comments
    - match algroithm try improvements.
    - find a way to obtain the list of classes besides the contructor.
    _ make thread safe.
    - pass error down recurse methods.
    -handle all java types LinkList ....
     -verify cache strategy - is object unique.


 */

/*

  id and description not follow the usual pattern as they use double underscore
  '__' convention

 */

#import "PacoSerializer.h"
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#include "java/util/HashMap.h"
#include "java/util/ArrayList.h"
#include "java/util/iterator.h"
#import "ITAhoCorasickContainer.h"
#import "NSObject+J2objcKVO.h"
#include "java/util/ArrayList.h"
#include "java/util/List.h"
#include "java/lang/Boolean.h"
#include "java/lang/Long.h"
#include "java/lang/Integer.h"
#include "java/lang/Float.h"
#include "java/lang/Double.h"
#include "java/lang/Boolean.h"
#import "SignalTime.h" 
#import "PacoIntrospectHelper.h"



#define METHOD_PREFIX @"PA"

@interface PacoSerializer ()

@property(nonatomic, strong) NSMutableArray* objectTracking;

/* serilized json */
@property(nonatomic, strong) NSArray* mappings;


/* serilized json */
@property(nonatomic, strong) NSString* nameOfClass;

/* serilized json */
@property(nonatomic, strong) NSArray* classes;

/* serilized json */
@property(nonatomic, strong) NSCache* cache;

/* serilized json */
@property(nonatomic, strong) NSMutableDictionary* attributeClassMap;
/* aho corasic matching algorithm */
@property(strong, nonatomic) ITAhoCorasickContainer* container;
/* The first or parent node  */
@property(nonatomic, strong) id parentNode;
/* collection object */
@property(nonatomic, strong) id parentCollection;
@end

@implementation PacoSerializer

#pragma mark - public methods




/*
     initialize the object with a list of the names of the files generated by
   j2objc
 */
- (instancetype)initWithArrayOfClasses:(NSArray*) classes  withNameOfClassAttribute:(NSString*) nameOfClass
{
  self = [super init];
  if (self) {
      
         _classes = classes;
        _nameOfClass = nameOfClass;
        _objectTracking = [NSMutableArray new];
        _cache = [NSCache new];
        _container = [ITAhoCorasickContainer new];
        _attributeClassMap = [NSMutableDictionary new];
        [self buildAttibuuteClassMap];
     
  }
  return self;
}

- (instancetype) initWithArrayWithClassAttributeName: (NSString*) nameOfClass
{
    self = [super init];
    if (self) {
        
    
        _nameOfClass = nameOfClass;
        _objectTracking = [NSMutableArray new];
        _cache = [NSCache new];
        
    }
    return self;
}

 

- (NSObject*)toJ2OBJCCollctionsHeirarchy:(NSObject*)parent {
  _parentCollection = nil;
  [_objectTracking removeAllObjects];
  [self recurseObjectHierarchy:@[ PACO_OBJECT_PARENT, parent ]];
  return _parentCollection;
}

- (NSData *)toJSONobject:(NSObject*)parent {
  _parentCollection = nil;
  [_objectTracking removeAllObjects];
    
    JavaUtilArrayList* arrayList = [[JavaUtilArrayList alloc] initWithInt:1];
    [arrayList addWithId:parent];
    
  [self recurseObjectHierarchy:@[ PACO_OBJECT_PARENT, arrayList ]];
  NSError* error2 = nil;
  NSData* newData =
      [NSJSONSerialization dataWithJSONObject:_parentCollection
                                      options:NSJSONWritingPrettyPrinted
                                        error:&error2];
  return newData;
}

- (NSData*)foundationCollectionToJSONData:(NSObject*)collection
                                    Error:(NSError*)error {
  NSData* data =
      [NSJSONSerialization dataWithJSONObject:_parentCollection
                                      options:NSJSONWritingPrettyPrinted
                                        error:&error];
  return data;
}

- (NSObject*)buildObjectHierarchyFromCollections:(id)collection {
  _parentNode = nil;
  [self recurseJason:@[ PACO_OBJECT_PARENT, collection ]];
  return _parentNode;
}

- (NSObject*)buildObjectHierarchyFromJSONOBject:(id)data {
  _parentNode = nil;
  NSError* error;
  id definitionDict =
      [NSJSONSerialization JSONObjectWithData:data
                                      options:NSJSONReadingAllowFragments
                                        error:&error];
    
    

  [self recurseJason:@[ PACO_OBJECT_PARENT, @[definitionDict] ]];
  return _parentNode;
}

- (void)validate:(NSArray*)parentInfo {
  if ([parentInfo[1] isKindOfClass:[JavaUtilArrayList class]]) {
    NSArray* myArray = (NSArray*)[parentInfo[1] toArray];
    for (NSObject* o in myArray) {
      [self validate:@[ parentInfo[0], o ]];
    }

  } else if ([parentInfo[1] isKindOfClass:[JavaUtilHashMap class]]) {
    NSArray* myArray = (NSArray*)[[parentInfo[1] keySet] toArray];
    for (NSString* str in myArray) {
      [self validate:@[ str, [parentInfo[1] valueForKey:str] ]];
    }
  } else {
    if (![parentInfo[1] isKindOfClass:[NSString class]] &&
        ![parentInfo[1] isKindOfClass:[NSNumber class]]) {
      // validate

      NSLog(@"call validate on %@", parentInfo[1]);

      NSObject* object = parentInfo[1];
      unsigned int numIvars = 0;
      Ivar* ivars = class_copyIvarList([object class], &numIvars);
      for (int i = 0; i < numIvars; i++) {
        NSString* ivarName = [NSString stringWithCString:ivar_getName(ivars[i])
                                                encoding:NSUTF8StringEncoding];
        NSObject* o = object_getIvar(object, ivars[i]);
        if (o) {
          [self validate:@[ ivarName, o ]];
        }
      }

    } else {
    }
  }
}

/*
    build a foundation collection hierarchy from j2objc model objects.

 */

- (void)recurseObjectHierarchy:(NSArray*)parentInfo {
    
    NSLog(@"   %@", parentInfo);
    if ([parentInfo[1] isKindOfClass:[JavaUtilArrayList class]]  || [parentInfo[1] conformsToProtocol:@protocol(JavaUtilList)]   ) {
    NSArray* myArray = (NSArray*)[parentInfo[1] toArray];
    NSMutableArray* mArray = [NSMutableArray new];
    [self addToCollection:parentInfo[0] Value:mArray];
    [self push:mArray];

    for (NSObject* o in myArray) {
      [self recurseObjectHierarchy:@[ parentInfo[0], o ]];
    }
    [self pop];

  } else if ([parentInfo[1] isKindOfClass:[JavaUtilHashMap class]]) {
    NSMutableDictionary* mutableDictionary = [NSMutableDictionary new];
    [self addToCollection:parentInfo[0] Value:mutableDictionary];
    [self push:mutableDictionary];

    NSArray* myArray = (NSArray*)[[parentInfo[1] keySet] toArray];
    for (NSString* str in myArray) {
      [self recurseObjectHierarchy:@[ str, [parentInfo[1] valueForKey:str] ]];
    }
    [self pop];

  } else {
      
      NSObject *o =parentInfo[1];
      /* add case for boolean*/
    if (
        
    [ o.superclass isKindOfClass:[PAModelBase class]] ||
    [ o isKindOfClass:[PAModelBase class]]
        
        
        /*
        ![parentInfo[1] isKindOfClass:[NSString class]] &&
        ![parentInfo[1] isMemberOfClass:[NSNumber class]] &&
        ![parentInfo[1] isMemberOfClass:[JavaLangBoolean class]] &&
        ![parentInfo[1] isMemberOfClass:[JavaLangInteger class]] &&
         ![parentInfo[1] isMemberOfClass:[JavaLangLong class]] &&
         */
 
        )
    {
        
     /* assuming this is a   object */ 
      NSMutableDictionary* mutableDictionary = [NSMutableDictionary new];
      [self addToCollection:parentInfo[0] Value:mutableDictionary];
      [self push:mutableDictionary];
      NSObject* object = parentInfo[1];
      unsigned int numIvars = 0;

      NSObject* interObject = object;
      while (![interObject isMemberOfClass:[NSObject class]]) {
        Ivar* ivars = class_copyIvarList([interObject class], &numIvars);
        for (int i = 0; i < numIvars; i++) {
            
            
          NSString* ivarName =
              [NSString stringWithCString:ivar_getName(ivars[i])
                                 encoding:NSUTF8StringEncoding];
            
            
            
            NSArray* array = [PacoIntrospectHelper parseIvar:ivars[i] Parent:parentInfo[1]];
            NSObject *  oo =nil;
            
            
            oo= array[0];
          
      
          if (oo) {
              
            [self recurseObjectHierarchy:@[[self trimTrailingUnderscore:ivarName], oo ]];
          }
        }
        interObject = [[interObject.superclass alloc] init];
        ;
      }

      [self pop];
    } else {
        
      NSString * name =  [self trimTrailingUnderscore:parentInfo[0]];
      [self addToCollection:name Value:parentInfo[1]];
    }
  }
}




/*
    adds an object to an array list

 */
- (BOOL)addObjectToArray:(NSString*)attributeName
                  Object:(NSObject*)object
                   Value:(NSObject*)val {
  BOOL success = YES;
  JavaUtilArrayList* array = [self getArrayList:attributeName Object:object];
  success = [array addWithId:val];
  return success;
}

- (NSString*)ahoCorasickMatcher:(NSDictionary*)dictionary {
  NSArray* keys = [dictionary allKeys];
  keys = [keys
      sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];

  NSMutableString* mutableString = [NSMutableString new];
  for (NSString* key in keys) {
    [mutableString appendString:key];
  }

  return mutableString;
}

/*


    compare list of ivars with dictionary keys to find the closest match
    refactor out of >1 selection

 */
- (NSObject*)match:(NSArray*)recurseObject {
  NSString* clazzName = nil;
  NSDictionary* dictionary = recurseObject[1];
  id object = nil;
  clazzName = dictionary[_nameOfClass];
  NSRange r1 = [clazzName rangeOfString:@"." options:NSBackwardsSearch];
  clazzName = [clazzName substringFromIndex:r1.location + 1];
  clazzName = [NSString stringWithFormat:@"PA%@", clazzName];
  Class theClass = NSClassFromString(clazzName);
  object = [[theClass alloc] init];
  assert(object);
  return object;
}



- (void)addToCollection:(NSString*)attributeName Value:(NSObject*)object {
  NSObject* parent = [self parent];
  /*
   lets handle three cases for the parent
      A) parent could be a list object
      B) parent could be a dictionary object.
      */

  if ([parent isKindOfClass:[NSMutableArray class]]) {
    if (_parentCollection == nil) {
      _parentCollection = object;
    } else {
      [((NSMutableArray*)parent)addObject:object];
    }

  } else if ([parent isKindOfClass:[NSMutableDictionary class]]) {
    /*
     Case B, we add the object to the parent using the key.
     */

    if (_parentCollection == nil) {
      _parentCollection = object;
    } else {
        
       /* here we need to go back to the pure objective c type */
        
      [((NSMutableDictionary*)parent)setValue:object forKey:attributeName];
        
        
        
    }
  }
}

- (void)addItem:(NSString*)attributeName
         Parent:(NSObject*)parent
          Value:(NSObject*)object
        AddList:(BOOL)addList {
  /*
   lets handle three cases for the parent
   A) parent could be a list object
   B) parent could be a dictionary object.
   C) parent could be a model object.

   */

  if ([parent isKindOfClass:[JavaUtilArrayList class]]) {
    /*
     Case A: We now just add the object to the list.

     */
    [((JavaUtilArrayList*)parent)addWithId:object];
  } else if ([parent isKindOfClass:[JavaUtilHashMap class]]) {
    /*
     Case B, we add the object to the parent using the key.
     */
    [((JavaUtilHashMap*)parent)setValue:object forKey:attributeName];
  } else {
    /*
     Case C, we set the attribute on  the parent using the key and key value
     coding

     */
      
     
   
      
         
      
    if (addList ) {
        
             [parent setValueEx:object forKey:attributeName];
    }
  }
}

/*

    parses the colection tree in order, building the model tree.


 */

- (void)recurseJason:(id)recurseObject {
  /*


  /*
      object could be

       1) a dictionary representation of a model object
       2) a list of objects
       3) an attribute value

     key could be
       1) the name of an ivar
       2) a well know name
       3) nil

   */

  /*  (1) object is a dictionary */
  if ([recurseObject[1] isKindOfClass:[NSDictionary class]]) {
    /* optimzation can be achieved by fetching the parent and if its not a list
      find the type of the iver
      with of the same name */

    /* lets check to see if the dictionary matches an model object */
    id object = [self match:recurseObject];

    /*
      if the object exists we create it and add to the parent
      if the object does not exist we should add it as a dictionary to the
      parent

     */

    /*
       up the dictionary matches a model object. Now lets add the object to the
       paretn
     */
    if (object) {
      /* lets get the name of the attribute that holds this model*/
      NSString* attributeName = recurseObject[0];
      NSObject* parent = [self parent];
      [self addItem:attributeName Parent:parent Value:object AddList:YES];
      // push the object so to make it the current worked on object.
      [self push:object];
    } else {
      // bona fide dictionary
      // push dictionary map.
      /*
       for( key in array of keys_
        [self recurseJason:@[key,newObject]   Block:block];
       */
    }

    /*
         Handle each of the element in the dictionary
     */
    NSArray* arrayOfKeys = [recurseObject[1] allKeys];
    /* loop over all keys and recursively this method. */
    for (NSString* key in arrayOfKeys) {
      id newObject = [recurseObject[1] objectForKey:key];
      if (newObject != [NSNull null]) {
        [self recurseJason:@[ key, newObject ]];
      }
    }

    // we are  done handling this object so pop it from the stack.
    if (object) {
      // NSLog(@"pop  object %@ for key %@",matchedClass, recurseObject[0]);
      // lets pop the object.
      [self pop];
    } else {
      // bona fide ditionary
      // pop
    }
  }
  /* case  (2) object is a list  */
  else if ([recurseObject[1] isKindOfClass:[NSArray class]]) {
    /*
     case this is a list attribute.
     */

    JavaUtilArrayList* arrayList = [[JavaUtilArrayList alloc] initWithInt:20];
    NSString* attributeName = recurseObject[0];
    NSObject* parent = [self parent];

    /* lets check to be sure the list is not the parent node
     we might be as good chaning this so it checks if parent object is nil
     */
    if (![recurseObject[0] isEqualToString:PACO_OBJECT_PARENT]) {
      [self addItem:attributeName Parent:parent Value:arrayList AddList:NO];
    } else {
      /* this is the first list or parent object so we want to set it as the
       * root object */
      _parentNode = arrayList;
    }

    id al = [parent valueForKeyEx:attributeName];
    if (al == nil) {
      [self push:arrayList];
    } else {
      [self push:al];
    }

    for (NSObject* obj in recurseObject[1]) {
      [self recurseJason:@[ recurseObject[0], obj ]];
    }

    [self pop];

    if ([arrayList isEmpty] != 0 && al == nil) {
      [[self parent] setValueEx:arrayList forKey:attributeName];
    }

  } else  // Not a list and not a dictionary.
  {
    /* we know recurseObject[1] is not a list and we know recurseObject[1] not a
     dictionary so it is an elemental type
     Parent could be an array or map or boject */

    NSObject* parent = [self parent];
    NSObject* object = recurseObject[1];
    NSString* attributeName = recurseObject[0];
      
      
      [self addItem:attributeName Parent:parent Value:object AddList:YES];

    if ([object isKindOfClass:[NSNumber class]]) {
        
        
     // [self addItem:attributeName Parent:parent Value:object AddList:YES];
        
        
        
        
        
    } else if ([object isKindOfClass:[NSString class]]) {
      /* (3) object is not a list and not a dictionary. It's a non list non
       dictionary  attribute on a dictionary or an element of a list
       requires converting to a new value */

      //[self addItem:attributeName Parent:parent Value:object AddList:YES];
    }

    NSLog(@"Setting value %@ for key %@ on class %@", recurseObject[1],
          recurseObject[0], [[self parent] class]);
  }
}

#pragma mark - intersection match strategy

- (void)buildAttibuuteClassMap {
  for (NSString* className in _classes) {
    NSString* withPrefix =
        [NSString stringWithFormat:@"%@%@", METHOD_PREFIX, className];
    Class theClass = NSClassFromString(withPrefix);
    id object = [[theClass alloc] init];

      
 
      
    NSArray* ivarNameArray = [self arrayOfIvarsNamesFromInstance:object];

    for (NSString* name in ivarNameArray) {
      NSString* trimmedName = [self trimTrailingUnderscore:name];

      if (![[_attributeClassMap allKeys] containsObject:trimmedName]) {
        [_attributeClassMap setObject:[NSMutableSet new] forKey:trimmedName];
      }

      NSMutableSet* set = [_attributeClassMap objectForKey:trimmedName];
      [set addObject:withPrefix];
    }

    NSLog(@" class map %@", _attributeClassMap);
  }
}

- (NSString*)findClassNameFromAttributes:(NSMutableArray*)attibutes {
    
   
    
    
  NSMutableSet* topSet = [_attributeClassMap objectForKey:attibutes[0]];
  for (NSString* att in attibutes) {
      
      
      if([att isEqualToString:_nameOfClass] || [att isEqualToString:@"byDayOfWeek"])
          continue;
      
    NSLog(@"thisone -%@", att);
    NSMutableSet* set = [_attributeClassMap objectForKey:att];
    [topSet intersectSet:set];
      
      if([topSet count] ==0)
      {
           NSLog(@"problem att -%@", att);
          
      }
  }
  return [topSet anyObject];
}

#pragma mark - aho corassic

/*


  build search strings for each of the classes

 */

- (void)buildSearchStrings {
  for (NSString* className in _classes) {
    NSString* withPrefix =
        [NSString stringWithFormat:@"%@%@", METHOD_PREFIX, className];
    Class theClass = NSClassFromString(withPrefix);
    id object = [[theClass alloc] init];
    [self.container addStringPattern:[self toMatchString:object]];
  }
}

/*
    trim the last '_' characters
 */
- (NSString*)trimTrailingUnderscore:(NSString*)str {
  NSString* trimmed = nil;
  NSRange r1 = [str rangeOfString:@"_"];
    
    if( r1.location !=  NSNotFound)
    {
        trimmed = [str substringToIndex:r1.location];
    }
    else
    {
        
        trimmed = str;
    }
  return trimmed;
}

/*

  create an Aho-Corasick search string.

 */
- (NSString*)toMatchString:(NSObject*)object {
  NSMutableString* mutableString = [NSMutableString new];

  // [mutableString  appendString:NSStringFromClass([object class])];
  // [mutableString  appendString:@":"];
  unsigned int numIvars = 0;
  NSMutableArray* mArray = [NSMutableArray new];
  Ivar* ivars = class_copyIvarList([object class], &numIvars);
  for (int i = 0; i < numIvars; i++) {
    NSString* ivarName = [NSString stringWithCString:ivar_getName(ivars[i])
                                            encoding:NSUTF8StringEncoding];
    NSString* trimmedName = [self trimTrailingUnderscore:ivarName];
    [mArray addObject:trimmedName];
  }

  /* recurse over the superclasses retrieving the ivars and appending to the
   * string*/
  while (YES) {
    Class superclass = class_getSuperclass([object class]);
    id superclassObject = [[superclass alloc] init];
    if (![superclassObject isMemberOfClass:[NSObject class]]) {
      Ivar* ivars = class_copyIvarList([object class], &numIvars);
      for (int i = 0; i < numIvars; i++) {
        NSString* ivarName = [NSString stringWithCString:ivar_getName(ivars[i])
                                                encoding:NSUTF8StringEncoding];
        NSString* trimmedName = [self trimTrailingUnderscore:ivarName];
        [mArray addObject:trimmedName];
      }

    } else {
      /* we have reached NSObject so break out of loop*/

      break;
    }
  }

  NSArray* array = [mArray
      sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
  for (NSString* name in array) {
    [mutableString appendString:name];
  }
  NSLog(@" pattern : %@", mutableString);
  return mutableString;
}

#pragma mark - help methods

/*
     loops over knonwn classes and checks if the iVars of the class match the
   keyd of the dictionary
      brut force will be replaced with a more elegant method later.

 */

- (NSArray*)matchClassForDictionary:(NSDictionary*)dictionary {
  NSMutableArray* mArray = [NSMutableArray new];

  for (NSString* className in _classes) {
    NSString* withPrefix = [NSString stringWithFormat:@"PA%@", className];
    if ([self matchesClass:dictionary ClassName:withPrefix]) {
      [mArray addObject:withPrefix];
    }
  }
  return mArray;
}

/*

   brut force compars the keys in the dictioanry with the ivar of a class.
   returns true if match ratio is larger than MATCHER_SUCCESS_RATIO
 */
- (BOOL)matchesClass:(NSDictionary*)dictionary ClassName:(NSString*)className {
  NSArray* array = [dictionary allKeys];
  NSMutableArray* noArray = [NSMutableArray new];
  NSMutableArray* yesArray = [NSMutableArray new];
  Class theClass = NSClassFromString(className);
  id object = [[theClass alloc] init];

  NSArray* resultsArray = [self arrayOfIvarsFromInstance:object];

  for (NSString* string in array) {
    NSString* str = [NSString stringWithFormat:@"%@_", string];
    if ([resultsArray containsObject:str]) {
      [yesArray addObject:str];
    } else {
      [noArray addObject:str];
    }
  }
  float successRatio = (float)[yesArray count] / [array count];
  return (successRatio > PACO_MATCHER_SUCCESS_RATIO);
}

#pragma mark - more  helper methods runtime



/*
 
 get an array of ivars from a class instance
 
 */

- (NSArray*)arrayOfIvarsNamesFromInstance:(id)object {
    
    NSMutableArray* resultsArray =[NSMutableArray new];
    
 
        
        NSObject* interObject = object;
        unsigned int numIvars;
        while (![interObject isMemberOfClass:[NSObject class]]) {
            Ivar* ivars = class_copyIvarList([interObject class], &numIvars);
            for (int i = 0; i < numIvars; i++) {
                NSString* ivarName =
                [NSString stringWithCString:ivar_getName(ivars[i])
                                   encoding:NSUTF8StringEncoding];
                [resultsArray addObject:ivarName];
            }
            interObject = [[interObject.superclass alloc] init];
            free(ivars);
            
        }
        
        
         
   
    return resultsArray;
}

/*

   get an array of ivars from a class instance

 */

- (NSArray*)arrayOfIvarsFromInstance:(id)object {
  NSMutableArray* resultsArray;
  resultsArray = [_cache objectForKey:object];
  if (!resultsArray) {
    resultsArray = [NSMutableArray new];
    unsigned int numIvars = 0;
    Ivar* ivars = class_copyIvarList([object class], &numIvars);

    for (int i = 0; i < numIvars; ++i) {
      Ivar ivar = ivars[i];

      NSString* ivarName = [NSString stringWithCString:ivar_getName(ivar)
                                              encoding:NSUTF8StringEncoding];
      [resultsArray addObject:ivarName];
    }

    Class superclass = class_getSuperclass([object class]);
    id superclassObject = [[superclass alloc] init];
    if (![superclassObject isMemberOfClass:[NSObject class]]) {
      [resultsArray
          addObjectsFromArray:[self arrayOfIvarsFromInstance:superclass]];
    }

    free(ivars);
    [_cache setObject:resultsArray forKey:object];
  }
  return resultsArray;
}

- (JavaUtilArrayList*)getArrayList:(NSString*)attributeName
                            Object:(NSObject*)object {
  JavaUtilArrayList* arrayList;
  arrayList = (JavaUtilArrayList*)[self valueForKeyEx:attributeName];
  return arrayList;
}

#pragma mark - Stack Methods

- (void)push:(id)item {
  [_objectTracking addObject:item];
}

- (NSObject*)parent {
  return [self peek];
}

- (id)pop {
  id item = nil;
  if ([_objectTracking count] != 0) {
    item = [_objectTracking lastObject];
    [_objectTracking removeLastObject];
  }
  return item;
}

- (id)peek {
  id item = nil;
  if ([_objectTracking count] != 0) {
    item = [_objectTracking lastObject];
  }
  return item;
}

- (void)replaceTop:(id)item {
  if ([_objectTracking count] == 0) {
    [_objectTracking addObject:item];
  } else {
    [_objectTracking removeLastObject];
    [_objectTracking addObject:item];
  }
}

@end
