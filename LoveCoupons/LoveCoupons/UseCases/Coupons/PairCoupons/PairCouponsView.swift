//
//  PairCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct PairCouponsView<ViewModel>: View where ViewModel: PairCouponsViewModelProtocol {
    private let defaultMinListRowHeight: CGFloat = 200

    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        LoadingView(isShowing: $viewModel.isShowLoading) {
            List {
                ForEach(Array(viewModel.coupons.enumerated()), id: \.element) { index, coupon in
                    CouponView(coupon: coupon, id: index + 1)
                        .onTapGesture {
                            viewModel.showSendEmailView(coupon: coupon)
                        }
                }
            }
            .environment(\.defaultMinListRowHeight, defaultMinListRowHeight)
            .listStyle(PlainListStyle())
            .navigationBarTitle(Text(""),displayMode: .inline)
            .navigationBarItems(leading: Text(L10n.PairCoupons.title.uppercased()).font(.custom(Constants.titleFont, size: 28)))
        }
        .onAppear(perform: self.onAppear)
    }
    
    private func onAppear() {
        UITableViewCell.appearance().selectionStyle = .none
        UITableView.appearance().separatorStyle = .none
        viewModel.updateViewData()
    }
}

struct PairCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        PairCouponsView(viewModel: PairCouponsViewModel(coordinator: PairCouponsCoordinator(rootNavigationController: nil, tabNavigationController: nil)))
    }
}
