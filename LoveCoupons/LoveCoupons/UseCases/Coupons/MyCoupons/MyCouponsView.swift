//
//  MyCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 04/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct MyCouponsView<ViewModel>: View where ViewModel: MyCouponsViewModelProtocol {
    private let defaultMinListRowHeight: CGFloat = 200
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        List {
            ForEach(Array(viewModel.isShowLoading ?
                          viewModel.viewDataItemsPlaceholder.enumerated() :
                          viewModel.coupons.enumerated()), id: \.element) { index, coupon in
                let id = index + 1
                CouponView(coupon: coupon, id: id, isShowingLoading: viewModel.isShowLoading)
                    .onTapGesture {
                        viewModel.couponSelected(coupon, id: id)
                    }
            }
            .onDelete(perform: viewModel.deleteItems)
        }
        .listStyle(PlainListStyle())
        .environment(\.defaultMinListRowHeight, defaultMinListRowHeight)
        .navigationBarTitle(Text(""),displayMode: .inline)
        .navigationBarItems(leading: Text(L10n.MyCoupons.title.uppercased()).font(.custom(Constants.titleFont, size: 28)),
                            trailing: PrimaryButton(title: L10n.Button.add, style: .fill) {
            viewModel.addCouponButtonSelected()
        })
        .onAppear(perform: self.onAppear)
    }
    
    private func onAppear() {
        UITableView.appearance().separatorColor = .clear
    }
}

struct MyCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCouponsView(viewModel: MyCouponsViewModel(coordinator: MyCouponsCoordinator(rootNavigationController: nil, tabNavigationController: nil)))
    }
}
