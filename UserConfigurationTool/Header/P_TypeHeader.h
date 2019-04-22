//
//  P_TypeHeader.h
//  UserConfigurationTool
//
//  Created by TsanFeng Lam on 2019/4/22.
//  Copyright © 2019 gzmiracle. All rights reserved.
//

#ifndef P_TypeHeader_h
#define P_TypeHeader_h

struct PlistColumnIdentifierType {
    NSString *Key;
    NSString *Type;
    NSString *Value;
};


struct PlistType {
    NSString *Dictionary;
    NSString *Array;
    
    NSString *Boolean;
    
    NSString *String;
    NSString *Number;
    NSString *Date;
    NSString *Data;
};

struct PlistBooleanType {
    
    NSString *Y;
    NSString *N;
};

static struct PlistColumnIdentifierType PlistColumnIdentifier = {@"Key", @"Type", @"Value"};
static struct PlistType Plist = {@"Dictionary", @"Array", @"Boolean", @"String", @"Number", @"Date", @"Data"};
static struct PlistBooleanType PlistBoolean = {@"YES", @"NO"};

#endif /* P_TypeHeader_h */
