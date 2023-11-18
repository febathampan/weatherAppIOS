//
//  ViewController.swift
//  WeatherApp
//
//  Created by user234888 on 11/16/23.
// Feba Thampan- Section 5 - MSD
//

import UIKit
import CoreLocation

class ViewController: UIViewController,CLLocationManagerDelegate {
    @IBOutlet weak var locationLabel: UILabel! //Label to display location
    @IBOutlet weak var currentWeather: UILabel! //Label to display current weather condition
    @IBOutlet weak var weatherImage: UIImageView! //Image to represent weather condition
    @IBOutlet weak var temperatureLabel: UILabel! //Label to display temperature
    @IBOutlet weak var humidityLabel: UILabel! //Label to display humidity
    @IBOutlet weak var windLabel: UILabel! //Label to display wind speed
    
    //Location Manager
    private var locationManager = CLLocationManager()
    private var weather: WeatherModel?
    
    //API details
    private let apiKey = "173c5d2d2b354722ef79a5ecb76cf4e1"
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
    
    //Configuring location manager
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
        
        //Get weather in WeatherModel struct
        getWeather(for: location) { result in
            switch result {
            case .success(let weatherResponse):
                DispatchQueue.main.async {
                    self.weather = WeatherModel(weatherResponse: weatherResponse)
                    self.generateLabels()
                }
            case .failure(let error): //Error message on failure
                print("Error fetching weather: \(error)")
            }
        }
    }
    
    /*
     * Function to generate all the label values to display
     */
    private func generateLabels() {
        guard let weather = weather else { return }
        
        locationLabel.text = "\(weather.city)"
        
        //Capitalising first letter
        let sentenceCaseDescription = weather.weatherDescription.prefix(1).capitalized + weather.weatherDescription.dropFirst()
        currentWeather.text = "\(sentenceCaseDescription)"
        
        // Switch statement to set the image based on the weather icon from API. System images are used
        switch weather.weatherIcon {
        case "01d":
            weatherImage.image = UIImage(systemName: "sun.max.fill")
        case "01n":
            weatherImage.image = UIImage(systemName: "moon.fill")
        case "02d", "02n":
            weatherImage.image = UIImage(systemName: "cloud.sun.fill")
        case "03d", "03n":
            weatherImage.image = UIImage(systemName: "cloud.fill")
        case "04d", "04n":
            weatherImage.image = UIImage(systemName: "cloud")
        case "09d", "09n":
            weatherImage.image = UIImage(systemName: "cloud.drizzle.fill")
        case "10d", "10n":
            weatherImage.image = UIImage(systemName: "cloud.rain.fill")
        case "11d", "11n":
            weatherImage.image = UIImage(systemName: "cloud.bolt.fill")
        case "13d", "13n":
            weatherImage.image = UIImage(systemName: "cloud.snow.fill")
        case "50d", "50n":
            weatherImage.image = UIImage(systemName: "cloud.fog.fill")
        default:
            weatherImage.image = UIImage(systemName: "questionmark.diamond.fill")
        }
        temperatureLabel.text = " \(weather.temperature)°C"
        humidityLabel.text = " \(weather.humidity)%"
        
        // Convert wind speed from m/s to km/h
        let windSpeedKmH = (weather.windSpeed * 3.6)
        //Rounding off to 2 digits
        windLabel.text = " \(windSpeedKmH.rounded()) km/h"
    }
    
    
    /**
     * Make APi call and put it to the struct. Handles API failures
     */
    private func getWeather(for coordinates: CLLocationCoordinate2D, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        let urlString = "\(baseURL)?lat=\(coordinates.latitude)&lon=\(coordinates.longitude)&units=metric&appid=\(apiKey)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0, userInfo: nil)))
            return
        }
        
        //Handling error
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(.failure(error!))
                return
            }
            
            //Read JSON to WeatherResponse
            do {
                let decoder = JSONDecoder()
                let weatherResponse = try decoder.decode(WeatherResponse.self, from: data)
                completion(.success(weatherResponse))
                print(weatherResponse)
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
    
    //Structs to support API response
    private struct WeatherResponse: Codable {
        let main: Main
        let weather: [Weather]
        let wind: Wind
    }
    
    private struct Main: Codable {
        let temp: Double
        let humidity: Int
    }
    
    private struct Weather: Codable {
        let description: String
        let icon: String
    }
    
    private struct Wind: Codable {
        let speed: Double
    }
    
    private struct WeatherModel {
        let city: String
        let weatherDescription: String
        let weatherIcon: String
        let temperature: Double
        let humidity: Int
        let windSpeed: Double
        
        init(weatherResponse: WeatherResponse) {
            self.city = "Waterloo" // Simulated location
            self.weatherDescription = weatherResponse.weather[0].description
            self.weatherIcon = weatherResponse.weather[0].icon
            self.temperature = weatherResponse.main.temp
            self.humidity = weatherResponse.main.humidity
            self.windSpeed = weatherResponse.wind.speed
        }
    }
}


