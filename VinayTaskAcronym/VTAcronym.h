//
//  VTAcronym.h
//  VinayTaskAcronym
//
//  Created by Vinay on 2/10/16.
//  Copyright © 2016 Vinay. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@protocol VTAcronym
@end

@interface VTAcronym : JSONModel

@property(nonatomic, retain) NSString *freq;
@property(nonatomic, retain) NSString *lf;
@property(nonatomic, retain) NSString *since;
@property(nonatomic, retain) NSArray<VTAcronym> *vars;

@end
