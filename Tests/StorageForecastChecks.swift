import Foundation

func checkStorageForecast() {
    precondition(StorageForecast.timeUntilFull(stock: 100, capacity: 300, hourlyRate: 20) == 36000)
    precondition(StorageForecast.timeUntilFull(stock: 300, capacity: 300, hourlyRate: 20) == 0)
    precondition(StorageForecast.timeUntilFull(stock: 310, capacity: 300, hourlyRate: 0) == 0)
    precondition(StorageForecast.timeUntilFull(stock: 10, capacity: 300, hourlyRate: 0) == nil)
    precondition(StorageForecast.timeUntilFull(stock: 299, capacity: 300, hourlyRate: 120) == 30)
    precondition(StorageForecast.timeUntilFull(stock: 100, capacity: 800, hourlyRate: 20) == 126000)
    print("Storage forecasts passed")
}
