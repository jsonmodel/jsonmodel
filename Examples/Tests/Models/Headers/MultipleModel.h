//
//  MultipleModel.h
//  Examples
//
//  Created by Seamus on 2018/3/1.
//  Copyright © 2018年 JSONModel. All rights reserved.
//

#import <JSONModel/JSONModel.h>

@interface MultipleModel : JSONModel
@property (strong, nonatomic) NSString *typeField;
@end

@interface MultipleCarModel : MultipleModel
@property (strong, nonatomic) NSString *body;
@property (strong, nonatomic) NSString *tire;
@end

@interface MultiplePicModel : MultipleModel
@property (strong, nonatomic) NSString *background;
@property (strong, nonatomic) NSString *foreground;
@end

@interface MultipleTestModel: JSONModel
@property (strong, nonatomic) NSArray *models;
@end
