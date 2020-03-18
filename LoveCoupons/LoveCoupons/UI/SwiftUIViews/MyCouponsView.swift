//
//  MyCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 04/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI

struct MyCouponsView: View {
    private let apiManager = APIManager.sharedInstance
    
    @State private var alertString: String = ""
    @State private var alertTitle: String = ""
    @State private var showingAlert = false
    @State private var coupons: [Coupon] = []

    var body: some View {
        NavigationView {
            List {
                ForEach(coupons) { coupon in
                    CouponView(coupon: coupon)
                    .contextMenu {
                        NavigationLink(destination: CouponView(coupon: coupon)) {
                            Text(L10n.Button.edit)
                            Image(systemName: "chevron.right.2")
                                .foregroundColor(.red)
                        }
                        Button(action: {
                            self.coupons = self.coupons.filter { $0.id != coupon.id }
                        }){
                            Text(L10n.Button.delete)
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationBarItems(leading: Text(L10n.MyCoupons.title).font(.title),
                            trailing: PrimaryButton(title: L10n.Button.add, style: .fill, maxWidth: .none) {
                
            })
        }
        .padding(.top, 16)
        .alert(isPresented: $showingAlert) { () -> Alert in
            Alert(title: Text(alertTitle), message: Text(alertString))
        }
        .onAppear(perform: setList)
    }
    
    private func deleteItems(at offsets: IndexSet) {
        coupons.remove(atOffsets: offsets)
    }
            
    private func setList() {
        UITableView.appearance().separatorColor = .clear
        apiManager.getMyCoupons { coupons, error in
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

struct MyCouponsView_Previews: PreviewProvider {
    static var previews: some View {
        MyCouponsView()
    }
}
