//
//  ContentView.swift
//  RemoteCarSteering
//
//  Created by Julian Baumann on 20.03.23.
//

import SwiftUI
import SceneKit

struct ContentView: View {
    @StateObject var peripheralCommunication = PeripheralCommunication.shared
    @StateObject var steering = Steering.shared
    
    var body: some View {
        Grid {
            GridRow {
                GroupBox {
                    Button(action: {}) {
                        Image(systemName: "arrow.down")
                            .font(.system(size: 90))

                    }
                    .pressAction(
                        onPress: {
                            peripheralCommunication.changeAcceleration(direction: .backward)
                        },
                        onRelease: {
                            peripheralCommunication.changeAcceleration(direction: .none)
                        }
                    )
                    .padding(50)
                }
                
                Spacer()
                
                VStack {
                    CarModelView(rotation: $steering.rotation)

                    Button("Calibrate!") {
                        steering.normalizeRotation()
                    }
                    .padding(.top)
                    .buttonStyle(.borderedProminent)
                }
                
                Spacer()
            
                GroupBox {
                    Button(action: {}) {
                        Image(systemName: "arrow.up")
                            .font(.system(size: 90))
                    }
                    .pressAction(
                        onPress: {
                            peripheralCommunication.changeAcceleration(direction: .forward)
                        },
                        onRelease: {
                            peripheralCommunication.changeAcceleration(direction: .none)
                        }
                    )
                    .padding(50)
                }
                
                .sheet(isPresented: !$peripheralCommunication.connected) {
                    VStack {
                        Spacer()
                        ProgressView()
                        Text("Searching...")
                            .bold()
                            .opacity(0.7)
                            .padding(.top, 20)

                        Text("Check whether Bluetooth is enabled and the car is within range")
                            .opacity(0.4)

                        Spacer()
                    }
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
