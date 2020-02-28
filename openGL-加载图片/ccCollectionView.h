//
//  ccCollectionView.h
//  JZJSClub-Client
//
//  Created by mac on 2019/9/19.
//  Copyright © 2019 tdy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ccCollectionView : UIView

//创建collecitonView
- (instancetype)initCollectionViewWithframe:(CGRect)frame itemClass:(Class)itemClass headClass:(nullable Class)headClass footClass:(nullable Class)footClass;

- (instancetype)initCollectionViewWithItemClass:(Class)itemClass headClass:(nullable Class)headClass footClass:(nullable Class)footClass;

- (void)cc_reload;//刷新

- (void)cc_reloadSections:(NSIndexSet*)sections;//刷新

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *layout;

#pragma mark ------------------------- typedef -------------------------

/**
 * view
 */
typedef UICollectionViewCell* _Nonnull (^cc_CollectionViewForCell)(NSIndexPath *indexPath,UICollectionView* collectionView);
typedef UICollectionReusableView* _Nonnull (^cc_CollectionviewForElementOfKind)(NSIndexPath *indexPath,NSString*kind,UICollectionView* collectionView);

/**
 * 数量
 */
typedef NSInteger (^cc_CollectionNumberOfSections)(UICollectionView* collectionView);
typedef NSInteger (^cc_CollectionNumberOfRows)(NSInteger section,UICollectionView* collectionView);

/**
 * 点击
 */
typedef void (^cc_CollectionDidSelectRowAtIndexPath)(NSIndexPath *indexPath,UICollectionView* collectionView);

/**
 * 高度
 */

typedef CGSize (^cc_referenceSizeForHeaderInSection)(UICollectionView* collectionView,UICollectionViewLayout* layout,NSInteger section);
typedef CGSize (^cc_referenceSizeForFooterInSection)(UICollectionView* collectionView,UICollectionViewLayout* layout,NSInteger section);
typedef CGSize (^cc_sizeForItemAtIndexPath)(UICollectionViewLayout* layout,NSIndexPath* indexPath);

#pragma mark ------------------------- property -------------------------
/**
 * 头尾视图
 */
@property(nonatomic,copy,readonly) ccCollectionView *(^cc_CollectionviewForElementOfKind)(cc_CollectionviewForElementOfKind block);

/**
 * cell视图
 */
@property(nonatomic,copy,readonly) ccCollectionView *(^cc_CollectionNumberOfSections)(cc_CollectionNumberOfSections block);
@property(nonatomic,copy,readonly) ccCollectionView *(^cc_CollectionNumberOfRows)(cc_CollectionNumberOfRows block);
@property(nonatomic,copy,readonly) ccCollectionView *(^cc_CollectionViewForCell)(cc_CollectionViewForCell block);

/**
 * 点击
 */
@property(nonatomic,copy,readonly) ccCollectionView *(^cc_CollectionDidSelectRowAtIndexPath)(cc_CollectionDidSelectRowAtIndexPath block);

/**
 * 高度
 */
@property(nonatomic,copy,readonly) ccCollectionView *(^cc_sizeForItemAtIndexPath)(cc_sizeForItemAtIndexPath block);

@end

NS_ASSUME_NONNULL_END
