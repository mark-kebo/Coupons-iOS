//
//  PairCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct PairCouponsView: View {
    private let apiManager: APIManagerProtocol = APIManager.sharedInstance

    @State private var alertString: String = ""
    @State private var alertTitle: String = ""
    @State private var showingAlert = false
    @State private var coupons: [Coupon] = []
    @State private var isShowLoading = false

    var body: some View {
        LoadingView(isShowing: $isShowLoading) {
            NavigationView {
                List(Array(self.coupons.enumerated()), id: \.offset) { index, coupon in
                    CouponView(coupon: coupon, id: index + 1)
                }
                .environment(\.defaultMinListRowHeight, 200)
                .navigationBarTitle(Text(""),displayMode: .inline)
                .navigationBarItems(leading: Text(L10n.PairCoupons.title.uppercased()).font(.custom(Constants.titleFont, size: 28)))
            }
            .alert(isPresented: self.$showingAlert) { () -> Alert in
                Alert(title: Text(self.alertTitle), message: Text(self.alertString))
            }
            .onAppear(perform: self.onAppear)
        }
    }
    
    private func onAppear() {
        coupons.removeAll()
        UITableViewCell.appearance().selectionStyle = .none
        UITableView.appearance().separatorStyle = .none
        isShowLoading = true
        apiManager.getPairCoupons { coupons, error in
            if let error = error?.localizedDescription {
                self.alertString = error
                self.showingAlert = true
            } else if let coupons = coupons {
                self.coupons = coupons.sorted { coupon1, coupon2 -> Bool in
                    coupon1.description < coupon2.description
                }
            }
            self.isShowLoading = false
        }
    }
}

struct PairCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        PairCouponsView()
    }
}
