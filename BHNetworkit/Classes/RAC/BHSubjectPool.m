//
//  BHSubjectPool.m
//  AFNetworking
//
//  Created by heboyce on 2018/1/26.
//

#import "BHSubjectPool.h"
#import <pthread/pthread.h>

#define BHPoolLock()    pthread_mutex_lock(&_lock)
#define BHPoolUnlock()  pthread_mutex_unlock(&_lock)

@interface BHSubjectPool(){
  
  pthread_mutex_t _lock;
  
}
@property (nonatomic,strong) NSMapTable           *mapTable;
@property (nonatomic,strong) NSMutableDictionary  *poolDic;
@end

@implementation BHSubjectPool

+ (instancetype)sharedPool{
  static id sharedInstance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  return sharedInstance;
}

- (instancetype)init{
  
  self = [super init];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReceiveMemory:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
  
  _poolDic  = [NSMutableDictionary dictionary];
  pthread_mutex_init(&_lock, NULL);
  
  return self;
  
}
  
- (void)handleReceiveMemory:(NSNotification *)not{
  
   BHPoolLock();
  
  NSArray *keyArr = [_poolDic allKeys];
  
  for(NSInteger index = 0;index < [keyArr count];index++){
    
    NSHashTable *table = [_poolDic objectForKey:[keyArr objectAtIndex:index]];
    
    if(table.count == 0){
      [_poolDic removeObjectForKey:[keyArr objectAtIndex:index]];
    }
    
  }
  
  BHPoolUnlock();
  
}
  
- (void)addSubject:(id<RACSubscriber>)subject identifier:(NSString *)identifer{
  
  if (!identifer || !subject) {
    return;
  }
  
  BHPoolLock();
  
  NSHashTable *table = [_poolDic valueForKey:identifer];
  if(!table){
    table = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    [_poolDic setObject:table forKey:identifer];
  }
  
  if (![table containsObject:subject]) {
      [table addObject:subject];
  }
  
  
  
  BHPoolUnlock();

}

- (NSArray<id<RACSubscriber>> *)allSubjects:(NSString *)identifier{
  
  BHPoolLock();
  NSHashTable *table =  [_poolDic valueForKey:identifier];
  BHPoolUnlock();
  
  return table.allObjects;
  
}

- (NSString *)description{
  
  NSArray *keyArr = [_poolDic allKeys];
  
  NSString *str = @"";
  
  for (NSString *key in keyArr) {
    
      NSHashTable *table =  [_poolDic valueForKey:key];
    
      NSLog(@"key:\t %@",key);
      str  = [str stringByAppendingString:[NSString stringWithFormat:@"key:\t %@",key]];
      NSLog(@"table items");
      str  = [str stringByAppendingString:[NSString stringWithFormat:@"table items"]];
      NSLog(@"%@", [table allObjects]);
      str  = [str stringByAppendingString:[NSString stringWithFormat:@"%@",[table allObjects]]];
    
  }
  
  return str;
  
}



@end
