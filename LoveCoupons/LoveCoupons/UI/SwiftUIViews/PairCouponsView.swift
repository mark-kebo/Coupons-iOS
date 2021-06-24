//
//  PairCouponsView.swift
//  LoveCoupons
//
//  Created by Dmitry Vorozhbicki on 06/03/2020.
//  Copyright © 2020 Dmitry Vorozhbicki. All rights reserved.
//

import SwiftUI
import MessageUI

struct PairCouponsView: View {
    private let apiManager: APIManagerProtocol = APIManager.sharedInstance

    @State private var alertString: String = ""
    @State private var alertTitle: String = ""
    @State private var showingAlert = false
    @State private var coupons: [Coupon] = []
    @State private var isShowLoading = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    @State private var isShowingMailView = false
    @State private var emailMessage: String = ""
    @State private var bodyMessage: String = ""

    var body: some View {
        LoadingView(isShowing: $isShowLoading) {
            NavigationView {
                List {
                    ForEach(Array(self.coupons.enumerated()), id: \.element) { index, coupon in
                        NavigationLink(destination: CouponView(coupon: coupon, id: index + 1)) {
                            CouponView(coupon: coupon, id: index + 1)
                                .onTapGesture {
                                    if MFMailComposeViewController.canSendMail() {
                                        self.isShowLoading = true
                                        self.apiManager.getPairEmail { (email, error) in
                                            self.isShowLoading = false
                                            if let error = error?.localizedDescription {
                                                self.alertString = error
                                                self.showingAlert = true
                                            } else if let email = email {
                                                self.emailMessage = email
                                            }
                                            self.bodyMessage = coupon.description
                                            self.isShowingMailView.toggle()
                                        }
                                    } else {
                                        self.alertString = L10n.Alert.mail
                                        self.showingAlert = true
                                    }
                                }
                        }
                    }
                }
                .environment(\.defaultMinListRowHeight, 200)
                .listStyle(PlainListStyle())
                .navigationBarTitle(Text(""),displayMode: .inline)
                .navigationBarItems(leading: Text(L10n.PairCoupons.title.uppercased()).font(.custom(Constants.titleFont, size: 28)))
            }
            .alert(isPresented: self.$showingAlert) { () -> Alert in
                Alert(title: Text(self.alertTitle), message: Text(self.alertString))
            }
            .sheet(isPresented: self.$isShowingMailView) {
                MailView(result: self.$result, email: self.$emailMessage, body: self.$bodyMessage)
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
