//
//  MyCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 04/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct MyCouponsView: View {
    private let apiManager: APIManagerProtocol = APIManager.sharedInstance

    @State private var alertString: String = ""
    @State private var alertTitle: String = ""
    @State private var showingAlert = false
    @State private var coupons: [Coupon] = []
    @State private var isShowLoading = false

    var body: some View {
        NavigationView {
            LoadingView(isShowing: $isShowLoading) {
                List {
                    ForEach(Array(self.coupons.enumerated()), id: \.element) { index, coupon in
                        NavigationLink(destination: CouponEditView(coupon: coupon, id: index + 1, state: .edit)) {
                            CouponView(coupon: coupon, id: index + 1)
                        }
                    }
                    .onDelete(perform: self.deleteItems)
                }
                .listStyle(PlainListStyle())
                .environment(\.defaultMinListRowHeight, 200)
                .navigationBarTitle(Text(""),displayMode: .inline)
                .navigationBarItems(leading: Text(L10n.MyCoupons.title.uppercased()).font(.custom(Constants.titleFont, size: 28)), trailing: PrimaryNavigationButton(title: L10n.Button.add, style: .fill, destination: CouponEditView(coupon: Coupon(), id: 0, state: .add)))
            }
            .alert(isPresented: self.$showingAlert) { () -> Alert in
                Alert(title: Text(self.alertTitle), message: Text(self.alertString))
            }
            .onAppear(perform: self.onAppear)
        }
    }
    
    private func deleteItems(at offsets: IndexSet) {
        self.isShowLoading = true
        guard let first = offsets.first else { return }
        apiManager.deleteCoupon(coupons[first]) { error in
            if let error = error?.localizedDescription {
                self.alertString = error
                self.showingAlert = true
            }
            self.isShowLoading = false
        }
    }
            
    private func onAppear() {
        self.isShowLoading = true
        coupons.removeAll()
        UITableView.appearance().separatorColor = .clear
        apiManager.getMyCoupons { coupons, error in
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

struct MyCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCouponsView()
    }
}
