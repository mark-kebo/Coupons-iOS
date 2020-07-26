//
//  PairCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct PairCouponsView: View {
    private let apiManager = APIManager.sharedInstance
    
    @State private var alertString: String = ""
    @State private var alertTitle: String = ""
    @State private var showingAlert = false
    @State private var coupons: [Coupon] = []

    var body: some View {
        NavigationView {
            List(Array(coupons.enumerated()), id: \.offset) { index, coupon in
                CouponView(coupon: coupon, id: index + 1)
            }
            .environment(\.defaultMinListRowHeight, 200)
            .navigationBarTitle(Text(""),displayMode: .inline)
            .navigationBarItems(leading: Text(L10n.PairCoupons.title.uppercased()).font(.custom("3dumb", size: 28)))
        }
        .alert(isPresented: $showingAlert) { () -> Alert in
            Alert(title: Text(alertTitle), message: Text(alertString))
        }
        .onAppear(perform: onAppear)
    }
    
    private func onAppear() {
        coupons.removeAll()
        UITableViewCell.appearance().selectionStyle = .none
        UITableView.appearance().separatorStyle = .none
        apiManager.getPairCoupons { coupons, error in
            if let error = error?.localizedDescription {
                self.alertString = error
                self.showingAlert = true
            } else if let coupons = coupons {
                self.coupons = coupons.sorted { coupon1, coupon2 -> Bool in
                    coupon1.description ?? "" < coupon2.description ?? ""
                }
            }
        }
    }
}

struct PairCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        PairCouponsView()
    }
}
