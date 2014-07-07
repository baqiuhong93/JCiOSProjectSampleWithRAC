//
//  SVREventListOperator.m
//  JCiOSProjectSample
//
//  Created by jimple on 14/7/7.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "SVREventListOperator.h"
#import "AFHTTPRequestOperation.h"
#import "AFURLRequestSerialization.h"
#import "EventListItemModel.h"

@implementation SVREventListOperator

- (RACSignal *)getEventListWithPageSize:(NSInteger)pageSize
                                pageNum:(NSInteger)pageNum
                             type1Param:(NSString *)param
{
    return [self getEventListWithPageSize:pageSize pageNum:pageNum param:param];
}


- (RACSignal *)getEventListWithPageSize:(NSInteger)pageSize
                                pageNum:(NSInteger)pageNum
                             type2Param:(NSString *)param
{
    return [self getEventListWithPageSize:pageSize pageNum:pageNum param:param];
}

- (RACSignal *)getEventListWithPageSize:(NSInteger)pageSize
                                pageNum:(NSInteger)pageNum
                                  param:(NSString *)param
{
    @weakify(self);
    return [[RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber){
        @strongify(self);
        NSMutableString *strURL = [[NSMutableString alloc] initWithString:@""];
        [strURL appendString:[NSString stringWithFormat:@"%@", [BaseSVRRequestOperator serverDomain]]];
        
        NSMutableDictionary *dicParam = [[NSMutableDictionary alloc] init];
        [dicParam setObject:@(pageSize) forKey:@"pageSize"];
        [dicParam setObject:@(pageNum) forKey:@"pageNum"];
        [dicParam setObject:param forKey:@"temp"];
        
        [self cancelRequest];
        
        AFHTTPRequestSerializer <AFURLRequestSerialization> * requestSerializer = [AFHTTPRequestSerializer serializer];
        NSMutableURLRequest *request = [requestSerializer requestWithMethod:@"GET" URLString:[[NSURL URLWithString:strURL] absoluteString] parameters:dicParam error:nil];
        
        [self addAppNameToUserAgent:request];    // 重设UserAgent
        
        self.afRequest = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        self.afRequest.responseSerializer = [AFJSONResponseSerializer serializer];
        
        NSMutableSet *set = [[NSMutableSet alloc] initWithSet:self.afRequest.responseSerializer.acceptableContentTypes];
        [set addObject:@"application/x-javascript"];
        self.afRequest.responseSerializer.acceptableContentTypes = set;
        
        [self.afRequest setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
         {

////////////////////////////////////////////////////////////////
// 假数据
             static NSInteger sTimes = 0;
             NSMutableArray *resultArray = [[NSMutableArray alloc] init];
             for (int i = 0; i < pageSize; i++)
             {
                 sTimes++;
                 [resultArray addObject:@{
                                          @"img" : @"",
                                          @"title" : [NSString stringWithFormat:@"The Title [%d]", sTimes],
                                          @"times" : [NSString stringWithFormat:@"%d", sTimes],
                                          }];
             }
////////////////////////////////////////////////////////////////

             NSMutableArray *eventArray = [[NSMutableArray alloc] init];
             for (NSDictionary *itemDic in resultArray)
             {
                 EventListItemModel *eventInfo = [MTLJSONAdapter modelOfClass:[EventListItemModel class] fromJSONDictionary:itemDic error:nil];
                 [eventArray addObject:eventInfo];
             }
                 [subscriber sendNext:eventArray];
                 [subscriber sendCompleted];
         }failure:^(AFHTTPRequestOperation *operation, NSError *error)
         {
             [subscriber sendError:error];
         }];
        
        [self.afRequest start];
        
        return [RACDisposable disposableWithBlock:^
                {
                }];
    }] doError:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}















































@end