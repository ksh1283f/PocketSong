import Foundation
import Network

final class NetworkMonitor{
    static let shared = NetworkMonitor()

    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    public private(set) var isConnected = false
    private var _connectionType:ConnectionType = .unknown
    public var connectionType:ConnectionType {
        get{
            return _connectionType
        }
        
        set(newValue) {
            if _connectionType == newValue{
                return
            }
            
            _connectionType = newValue
            
            switch _connectionType {
            case .unknown:
                notify(message:"disconnected")
            default:
                notify(message: "connected")
            }
        }
    }

    var observers: [Observer]
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }

    private init() {
        print("[NetworkMonitor] init")
        monitor = NWPathMonitor()
        self.observers = []
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
        }else {
            connectionType = .unknown
            print("unknown...")
        }
    }
}

extension NetworkMonitor : Subject {
    func subscribe(observer: Observer) {
        self.observers.append(observer)
    }
    
    func unSubscribe(observer: Observer) {
        if let idx = self.observers.firstIndex(where: {$0.id == observer.id}){
            self.observers.remove(at: idx)
        }
    }
    
    func notify(message: String) {
        for observer in observers{
            observer.update(message: message)
        }
    }
}
