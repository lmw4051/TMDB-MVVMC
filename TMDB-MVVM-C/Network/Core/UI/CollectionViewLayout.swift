//
//  CollectionViewLayout.swift
//  TMDB-MVVM-C
//
//  Created by David Lee on 4/13/26.
//

import UIKit

enum CollectionViewLayout {
  static func makeMovieGridLayout() -> UICollectionViewCompositionalLayout {
    // Item — occupies 50% of the group's width, estimated height
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.5),
      heightDimension: .estimated(280)
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    // Group — horizontal arrangement, full width, estimated height
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .estimated(280)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item, item]  // Two items per row
    )
    group.interItemSpacing = .fixed(16)
    
    // Section
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 16, leading: 16, bottom: 16, trailing: 16
    )
    
    // Footer (pagination loading)
    let footerSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(60)
    )
    let footer = NSCollectionLayoutBoundarySupplementaryItem(
      layoutSize: footerSize,
      elementKind: UICollectionView.elementKindSectionFooter,
      alignment: .bottom
    )
    section.boundarySupplementaryItems = [footer]
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
  static func makeSkeletonGridLayout() -> UICollectionViewCompositionalLayout {
    let itemSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(0.5),
      heightDimension: .absolute(280)  // Skeleton uses fixed height
    )
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(
      widthDimension: .fractionalWidth(1.0),
      heightDimension: .absolute(280)
    )
    let group = NSCollectionLayoutGroup.horizontal(
      layoutSize: groupSize,
      subitems: [item, item]
    )
    group.interItemSpacing = .fixed(16)
    
    let section = NSCollectionLayoutSection(group: group)
    section.interGroupSpacing = 16
    section.contentInsets = NSDirectionalEdgeInsets(
      top: 16, leading: 16, bottom: 16, trailing: 16
    )
    
    return UICollectionViewCompositionalLayout(section: section)
  }
}
