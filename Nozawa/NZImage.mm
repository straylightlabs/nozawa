//  Copyright © 2016 Straylight. All rights reserved.

#import "NZImage.h"

@implementation NZImage {
  NSMutableArray *_imap;
  int _r;
  NSMutableArray *_descs;
  NSMutableDictionary *_indexParams;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _imap = [NSMutableArray array];
    _r = 0;
    _descs = [NSMutableArray array];
  }
  return self;
}

@end
