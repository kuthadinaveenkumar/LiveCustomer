import SwiftUI
import MapKit

struct CustomerMapView: View {
    
    @StateObject private var socketManager = WebSocketManager()
    
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 17.476, longitude: 78.384),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    var body: some View {
        Map(
            coordinateRegion: $region,
            annotationItems: annotationPoints
        ) { point in
            MapMarker(coordinate: point.coordinate, tint: .red)
        }
        .onAppear {
            socketManager.connect()
        }
        .onDisappear {
            socketManager.disconnect()
        }
        .onChange(of: socketManager.deliveryBoyLocation) { wrapper in
            if let loc = wrapper?.coordinate {
                region.center = loc
            }
        }
    }
    
    private var annotationPoints: [MarkerPoint] {
        if let loc = socketManager.deliveryBoyLocation?.coordinate {
            return [MarkerPoint(coordinate: loc)] // Always 1 marker
        }
        return []
    }
}


struct MarkerPoint: Identifiable {
    let id = "customer_123"
    let coordinate: CLLocationCoordinate2D
}
