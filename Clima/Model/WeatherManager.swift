//
//  WeatherManager.swift
//  Clima
//
//  Created by JunHwan Kim on 2022/01/29.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import Foundation

protocol WeatherManagerDelegate{
    func didUpdateWeather(weather: WeatherModel)
    func didFailWithError(error : Error)
}

struct WeatherManager{
     let weatherURL = "https://api.openweathermap.org/data/2.5/weather?"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName: String) {
        let urlString = "\(weatherURL)q=\(cityName)&appid=462c4e7edfd0874d7f9c5eba541e3eb2&units=metric"
        print(urlString)
        performRequest(urlString: urlString)
    }
    
    func fetchWeather(latitude: Double, longitute: Double){
        let urlString = "\(weatherURL)lat=\(latitude)&lon=\(longitute)&appid=462c4e7edfd0874d7f9c5eba541e3eb2&units=metric"
        performRequest(urlString: urlString)
    }
    
    func performRequest(urlString : String){
        if let url = URL(string: urlString){
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url, completionHandler: handle(data: response: error:))
            task.resume()
        }
    }
    
    func handle(data: Data?, response: URLResponse?, error: Error?){
        if error != nil {
            self.delegate?.didFailWithError(error: error!)
            return
        }
        if let safeData = data{
            if let weather = self.parseJSON(weatherData: safeData) {
                self.delegate?.didUpdateWeather(weather: weather)
            }
        }
    }
    
    func parseJSON(weatherData: Data)-> WeatherModel?{
        let decoder = JSONDecoder()
        do{
            let decodeData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodeData.weather[0].id
            let temp = decodeData.main.temp
            let name = decodeData.name
            
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        }catch{
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
    
    
    
}
