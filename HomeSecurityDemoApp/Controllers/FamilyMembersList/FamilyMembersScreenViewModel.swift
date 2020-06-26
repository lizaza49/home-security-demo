//
//  FamilyMembersScreenViewModel.swift
//  HomeSecurityDemoApp
//
//  Created by Admin on 14/09/16.
//  Copyright © 2016 Admin. All rights reserved.
//

import Foundation
import RxDataSources
import RxSwift
import HomeSecurityAPI

struct FamilyMemberSection: SectionModelType {
    typealias Item = FamilyMember

    var header: String? = nil
    var items: [Item] = []
}

extension FamilyMemberSection {
    init(original: FamilyMemberSection, items: [Item]) {
        self = original
        self.items = items
    }
}

struct FamilyMembersState {
    let sections: [FamilyMemberSection]
    private let disposeBag = DisposeBag()

    init(sections: [FamilyMemberSection] = []) {
        self.sections = sections
    }

    func update() -> Observable<FamilyMembersState> {
        return CospaceServices.familyService.getFamilyMembersList(withImages: true).map { result in
            let atHome = result.filter { $0.isAtHome }
            let notAtHome = result.filter { !$0.isAtHome }
            return FamilyMembersState(sections: [FamilyMemberSection(header: "At Home", items: atHome),
                FamilyMemberSection(header: "Location unknown", items: notAtHome)])
        }
    }
}
