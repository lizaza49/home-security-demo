//
//  FamilyMembersController.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 14/09/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import HomeSecurityAPI

final class FamilyMembersController: UIViewController, UICollectionViewDelegate, ErrorsHandler, ErrorAlertConstructor, UICollectionViewDelegateFlowLayout {

    private var collectionView: UICollectionView!
    private var viewModel: FamilyMembersState = FamilyMembersState()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        navigationItem.title = "Family"
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 60, height: 92)
        layout.minimumInteritemSpacing = 26
        layout.minimumLineSpacing = 26
        layout.headerReferenceSize = CGSize(width: 50, height: 44)
        layout.sectionInset = UIEdgeInsetsMake(26, 26, 26, 26)
        collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.registerClass(FamilyMemberCell.self, forCellWithReuseIdentifier: "Cell")
        view.addSubview(collectionView)
        let headerNib = UINib(nibName: "FamilyMemberSectionHeader", bundle: nil)
        collectionView.registerNib(headerNib, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        let leftConstraint = NSLayoutConstraint(item: collectionView, attribute: .Left, relatedBy: .Equal, toItem: view, attribute: .Left, multiplier: 1, constant: 0)
        let rightConstraint = NSLayoutConstraint(item: collectionView, attribute: .Right, relatedBy: .Equal, toItem: view, attribute: .Right, multiplier: 1, constant: 0)
        let topConstraint = NSLayoutConstraint(item: collectionView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0)
        let bottomConstraint = NSLayoutConstraint(item: collectionView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0)
        [NSLayoutConstraint.activateConstraints([leftConstraint, rightConstraint, topConstraint, bottomConstraint])]

        let dataSource = RxCollectionViewSectionedReloadDataSource<FamilyMemberSection>()
        dataSource.configureCell = { (dataSource, cv, indexPath, element) in
            let cell = cv.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as! FamilyMemberCell
            cell.avatar.configureWithFamilyMember(element)
            return cell
        }
        dataSource.supplementaryViewFactory = { (dataSource, cv, kind, indexPath) in
            let title = dataSource.sectionModels[indexPath.section].header
            let view = self.collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "SectionHeader", forIndexPath: indexPath) as! FamilyMemberSectionHeader
            view.titleLabel.text = title
            view.titleLabel.textColor = UIColor.brownishGreyColor().colorWithAlphaComponent(0.6)
            return view
        }
        let viewWillAppearRx = rx_sentMessage(#selector(viewWillAppear))
        let reloadTableTrigger = viewWillAppearRx
            .flatMapLatest { _ in
            return self.viewModel.update().catchError { error in
                self.handleError(error)
                return Observable.just(self.viewModel)
            }
        }.doOn(onNext: { state in
            self.viewModel = state
        }).share()
        reloadTableTrigger
            .map { $0.sections }
            .bindTo(collectionView.rx_itemsWithDataSource(dataSource))
            .addDisposableTo(disposeBag)
    }
}
