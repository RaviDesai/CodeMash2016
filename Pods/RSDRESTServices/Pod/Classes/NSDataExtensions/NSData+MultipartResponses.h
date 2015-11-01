//
//  NSData+MultipartResponses.h
//  CEVFoundation
//
//  Created by Ravi Desai on 5/1/15.
//  Copyright (c) 2015 CEV. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (MultipartResponses)

- (NSArray *)multipartArray;
- (NSDictionary *)multipartDictionary;

@end
