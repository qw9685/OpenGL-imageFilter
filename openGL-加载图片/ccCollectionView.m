//
//  ccCollectionView.m
//  JZJSClub-Client
//
//  Created by mac on 2019/9/19.
//  Copyright © 2019 tdy. All rights reserved.
//

#import "ccCollectionView.h"

@interface ccCollectionView ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic,strong) Class itemClass;
@property (nonatomic,strong) Class headClass;
@property (nonatomic,strong) Class footClass;

/**
 * 头尾视图
 */
@property(nonatomic,copy) cc_CollectionviewForElementOfKind viewForElementOfKind;

/**
 * cell视图
 */
@property(nonatomic,copy) cc_CollectionNumberOfSections numberOfSections;
@property(nonatomic,copy) cc_CollectionNumberOfRows numberOfRows;
@property(nonatomic,copy) cc_CollectionViewForCell viewForCell;

/**
 * 点击
 */
@property (nonatomic,copy) cc_CollectionDidSelectRowAtIndexPath didSelectRowAtIndexPath;

/**
 * 高度
 */

@property (nonatomic,copy) cc_sizeForItemAtIndexPath sizeForItemAtIndexPath;


@end

@implementation ccCollectionView

- (instancetype)initCollectionViewWithframe:(CGRect)frame itemClass:(Class)itemClass headClass:(nullable Class)headClass footClass:(nullable Class)footClass{
    
    if (self = [super initWithFrame:frame]) {
        self.itemClass = itemClass;
        self.headClass = headClass;
        self.footClass = footClass;
        [self initCollectionView];
    }
    return self;
}

- (instancetype)initCollectionViewWithItemClass:(Class)itemClass headClass:(nullable Class)headClass footClass:(nullable Class)footClass{
    
    if (self = [super init]) {
        
        self.itemClass = itemClass;
        self.headClass = headClass;
        self.footClass = footClass;
        [self initCollectionView];
    }
    return self;
}

- (void)initCollectionView{
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:self.layout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = [UIColor whiteColor];
    
    if (self.itemClass) {
        [_collectionView registerClass:self.itemClass forCellWithReuseIdentifier:NSStringFromClass(self.itemClass)];
    }
    if (self.headClass) {
        [_collectionView registerClass:self.headClass forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:NSStringFromClass(self.headClass)];
    }
    if (self.footClass) {
        [_collectionView registerClass:self.footClass forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:NSStringFromClass(self.footClass)];
    }
    
    [self addSubview:self.collectionView];
}

-(void)layoutSubviews{
    self.collectionView.frame = self.bounds;
}

-(void)cc_reload{
    [self.collectionView reloadData];
}

- (void)cc_reloadSections:(NSIndexSet*)sections{
    [self.collectionView reloadSections:sections];
}

#pragma mark -------------- UICollectionViewDataSource --------------

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.numberOfSections?self.numberOfSections(collectionView) : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.numberOfRows?self.numberOfRows(section,collectionView) : 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    return self.viewForCell(indexPath, collectionView);
}

//头尾视图
- (UICollectionReusableView*)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    return self.viewForElementOfKind(indexPath,kind,collectionView);
}

#pragma mark ------------------------- UICollectionViewDelegateFlowLayout -------------------------
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.sizeForItemAtIndexPath) {
        return self.sizeForItemAtIndexPath(collectionViewLayout,indexPath);
    }
    return self.layout.itemSize;
}

#pragma mark -------------- UICollectionViewDelegate --------------

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if (self.didSelectRowAtIndexPath) {
        self.didSelectRowAtIndexPath(indexPath,collectionView);
    }
}


#pragma mark ------------------------- set&get -------------------------

-(ccCollectionView * _Nonnull (^)(cc_CollectionViewForCell _Nonnull))cc_CollectionViewForCell{
    return ^ccCollectionView*(cc_CollectionViewForCell block){
        if (block) {
            self.viewForCell = block;
        }
        return self;
    };
}

-(ccCollectionView * _Nonnull (^)(cc_CollectionviewForElementOfKind _Nonnull))cc_CollectionviewForElementOfKind{
    return ^ccCollectionView*(cc_CollectionviewForElementOfKind block){
        if (block) {
            self.viewForElementOfKind = block;
        }
        return self;
    };
}

-(ccCollectionView * _Nonnull (^)(cc_CollectionNumberOfSections _Nonnull))cc_CollectionNumberOfSections{
    return ^ccCollectionView*(cc_CollectionNumberOfSections block){
        if (block) {
            self.numberOfSections = block;
        }
        return self;
    };
}

-(ccCollectionView * _Nonnull (^)(cc_CollectionNumberOfRows _Nonnull))cc_CollectionNumberOfRows{
    return ^ccCollectionView*(cc_CollectionNumberOfRows block){
        if (block) {
            self.numberOfRows = block;
        }
        return self;
    };
}
-(ccCollectionView * _Nonnull (^)(cc_CollectionDidSelectRowAtIndexPath _Nonnull))cc_CollectionDidSelectRowAtIndexPath{
    return ^ccCollectionView*(cc_CollectionDidSelectRowAtIndexPath block){
        if (block) {
            self.didSelectRowAtIndexPath = block;
        }
        return self;
    };
}

-(ccCollectionView * _Nonnull (^)(cc_sizeForItemAtIndexPath _Nonnull))cc_sizeForItemAtIndexPath{
    return ^ccCollectionView*(cc_sizeForItemAtIndexPath block){
        if (block) {
            self.sizeForItemAtIndexPath = block;
        }
        return self;
    };
}

@end

