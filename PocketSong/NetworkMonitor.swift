import Foundation
import Network

final class NetworkMonitor{
    static let shared = NetworkMonitor()

    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    public private(set) var isConnected = false
    public private(set) var connectionType:ConnectionType = .unknown

    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        print("[NetworkMonitor] init")
        monitor = NWPathMonitor()
    }

    public func startMonitoring(){
        print("[NetworkMonitor] startMonitoring")
        monitor.start(queue:queue)
        monitor.pathUpdateHandler = { [weak self] path in
            print("[NetworkMonitor] path : \(path)")

            self?.isConnected = path.status == .satisfied
            self?.getConnectionType(path)

            if self?.isConnected == true{
                print("[NetworkMonitor] network is connected!")
            }else{
                print("[NetworkMonitor] network is disconnected!")
            }
        }
    }
    
    public func stopMonitoring(){
        print("[NetworkMonitor] stopMonitoring")
        monitor.cancel()
    }

    private func getConnectionType(_ path:NWPath){
        print("[NetworkMonitor] getConnectionType")
        if path.usesInterfaceType(.wifi){
            connectionType = .wifi
            print("[NetworkMonitor] connected wifi..")
        }else if path.usesInterfaceType(.cellular){
            connectionType = .cellular
            print("[NetworkMonitor] connected cellular..")
        }else if path.usesInterfaceType(.wiredEthernet){
            connectionType = .ethernet
            print("[NetworkMonitor] connected ethernet..")
            )
        }else {
            connectionType = .unknown
            print("unknown...")
        }
    }

}
