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
        LoadingView(isShowing: $viewModel.isShowLoading) {
            List {
                ForEach(Array(viewModel.coupons.enumerated()), id: \.element) { index, coupon in
                    let id = index + 1
                    CouponView(coupon: coupon, id: id)
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
        }
        .onAppear(perform: self.onAppear)
    }
    
    private func onAppear() {
        UITableView.appearance().separatorColor = .clear
        viewModel.getCoupons()
    }
}

struct MyCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCouponsView(viewModel: MyCouponsViewModel(coordinator: MyCouponsCoordinator(rootNavigationController: nil, tabNavigationController: nil)))
    }
}
