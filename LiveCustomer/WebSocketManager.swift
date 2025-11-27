import Foundation
import CoreLocation

struct LocationWrapper: Equatable {
    let coordinate: CLLocationCoordinate2D

    static func == (lhs: LocationWrapper, rhs: LocationWrapper) -> Bool {
        return lhs.coordinate.latitude == rhs.coordinate.latitude &&
               lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}


class WebSocketManager: ObservableObject {
    
    @Published var deliveryBoyLocation: LocationWrapper? = nil
    
    private var webSocketTask: URLSessionWebSocketTask?
    
    private let wsURL = URL(string: "wss://1989659a958d.ngrok-free.ap/ws")!

    func connect() {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: wsURL)
        webSocketTask?.resume()
        
        print("🔵 Connecting to WebSocket…")
        receiveMessage()
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
        print("🔴 WebSocket Disconnected")
    }
    
    private func receiveMessage() {
        print("Hiii")
        webSocketTask?.receive { [weak self] result in
            switch result {
                
            case .failure(let error):
                print("❌ WS Error:", error.localizedDescription)
                self?.reconnect()
                
            case .success(let message):
                switch message {
                case .string(let text):
                    self?.decodeJSON(text)
                    print("📨 Received WS Message:", text)
                default:
                    break
                }
                self?.receiveMessage()
            }
        }
    }
    
    private func decodeJSON(_ text: String) {
        guard let data = text.data(using: .utf8) else { return }
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let lat = json["lat"] as? Double,
           let long = json["long"] as? Double {

            DispatchQueue.main.async {
                let coord = CLLocationCoordinate2D(latitude: lat, longitude: long)
                self.deliveryBoyLocation = LocationWrapper(coordinate: coord)
            }
        }
    }
    
    private func reconnect() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.connect()
        }
    }
}
