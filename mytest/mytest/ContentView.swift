//
//  ContentView.swift
//  mytest
//
//  Created by Gustavo Parrado on 30/06/20.
//  Copyright © 2020 xyrer. All rights reserved.
//

import SwiftUI
import NavigationStack
import Combine

struct ContentView: View {
	@EnvironmentObject var user:ObservableUser
	@State private var gotoLogin = false
	
    var body: some View {
		NavigationStackView {
			PushView(destination: loginView(),isActive: self.$gotoLogin) {
				EmptyView()
			}
			VStack {
				Text("Hello")
				Button(action: {
					self.gotoLogin.toggle()
				}) {
					Image(systemName: "xmark")
				}
			}
		}
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
		ContentView()
    }
}


struct loginView:View {
	@EnvironmentObject var user:ObservableUser
	
	var body: some View {
		HZStack(name: "login") {
			Text("login view")
		}
		.onAppear() {
			self.user.loginAttempts = 0
		}
	}
}

struct HZStack<Content:View>:View {
	let name:String
	let content:()->Content
	
	var body: some View {
		ZStack(alignment: .topLeading) {
			self.content()
		}
		.edgesIgnoringSafeArea(.all)
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
		.navigationBarTitle("")
		.navigationBarHidden(true)
		.padding()
	}
	
	init(name:String,darkStatusBar:Bool?=true,@ViewBuilder content:@escaping ()-> Content) {
		self.name = name
		self.content = content
	}
}

class ObservableUser: ObservableObject {
	public var lockRemaining:Int = 0
	public let loginBlocked = PassthroughSubject<Bool,Never>()
	@Published var loginAttempts:Int = 0 {
		didSet {
			if loginAttempts >= 10 {
				self.lockLogin()
			}
		}
	}
	
	func lockLogin() {
		let now = Date()
		let unlockTime = now + 30
		self.lockRemaining = 30
		UserDefaults.standard.setValue(unlockTime, forKey: "unlockTime")
		self.loginBlocked.send(true)
	}
}
