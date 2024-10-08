//
//  HomeView.swift
//  WeatherPOC
//
//  Created by Jatin Patel on 8/21/24.
//

import SwiftUI
import Kingfisher
import CoreLocation

struct DashboardView: View {
    @ObservedObject var dashboardViewModel = DashboardViewModel()
    @ObservedObject var locationManager = LocationManager()
    @State private var selectedSearch: SearchResponse?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LoadingView(isShowing: dashboardViewModel.isLoading) {
                    content
                        .onAppear {
                            handleOnAppear()
                        }
                        .navigationTitle("Weather")
                        .padding()
                }
            }
        }
    }
    
    // Extracted content view to reduce complexity
    var content: some View {
        VStack {
            // MARK: - Search Location View
            searchLocationView
            
            // MARK: - Main Temperature Details
            DashboardWeatherView(weatherResponse: dashboardViewModel.weatherResponse)
            
            // MARK: - Multiple Weather Details
            DashboardWeatherDetailView(weatherResponse: dashboardViewModel.weatherResponse)
            Spacer()
        }
    }
    
    // Extracted search location view to reduce complexity
    var searchLocationView: some View {
        HStack {
            NavigationLink(destination: LocationSearchView(callBackSearchResponse: { place in
                self.selectedSearch = place
                dashboardViewModel.storeSelectedLocation(place)
            })) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .renderingMode(.original)
                        .foregroundColor(.black)
                        .padding(.leading, 20)
                    
                    Text(
                        (dashboardViewModel.weatherResponse?.name ?? "") + ", " + (dashboardViewModel.weatherResponse?.sys?.country ?? "")
                    )
                    .foregroundColor(.black)
                    .cornerRadius(15)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: 50)
                .background(.gray.opacity(0.4))
                .cornerRadius(15)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.gray, lineWidth: 1)
                )
            }
        }
    }
    
    // Handle onAppear logic in a separate function
    private func handleOnAppear() {
        Task {
            locationManager.callBackUpdatedLocation = { currentLocation in
                await dashboardViewModel.getSelectedLocation(currentLocation: currentLocation)
            }
            await dashboardViewModel.getSelectedLocation(currentLocation: locationManager.lastLocation)
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
