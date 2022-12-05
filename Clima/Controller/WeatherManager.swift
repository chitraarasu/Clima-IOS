
import Foundation

protocol WeatherManagerDeligate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error?)
}

struct WeatherManager {
    let weatherUrl = "https://api.openweathermap.org/data/2.5/weather?&appid=________&units=metric"
    
    var delegate: WeatherManagerDeligate?
    
    func fetchWeather(cityName: String?){
        let url = "\(weatherUrl)&q=\(cityName!)"
        performRequest(with: url)
    }
    
    func fetchWeatherForLocation(lat: String?, lon: String?){
        let url = "\(weatherUrl)&lat=\(lat!)&lon=\(lon!)"
        performRequest(with: url)
    }
    
    func performRequest(with url: String){
        if let url = URL(string: url) {
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: url) { data, response, error in
                if error != nil {
                    self.delegate?.didFailWithError(error: error)
                    return
                }
                
                if let safeData = data{
//                    let dataString = String(data: safeData, encoding: .utf8)
                    if let weather = self.parseJson(weatherData: safeData){
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            task.resume()
        }
    }
    
    func parseJson(weatherData: Data) -> WeatherModel? {
        let decoder = JSONDecoder()
        
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let name = decodedData.name
            let temp = decodedData.main.temp
            
            let weather = WeatherModel(conditionId: id, cityName: name, temprature: temp)
            return weather
        } catch {
            self.delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
