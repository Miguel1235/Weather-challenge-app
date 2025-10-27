import XCTest
@testable import iWeather

final class iWeatherUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        
        app = XCUIApplication()
        app.launchArguments.append("--uitesting")
        app.launchEnvironment["RESET_DATA"] = "1"
        app.launch()
    }

    override func tearDownWithError() throws {
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
    
    @MainActor
    func testDashboardViewToFavorites() throws {
        let favTab = app.tabBars.buttons["Favorites"].firstMatch
        XCTAssertTrue(favTab.waitForExistence(timeout: 5), "Favorites should appear on the tab bar")
        favTab.tap()
    }
    
    @MainActor
    func testDashboardViewToHistoryView() throws {
        let historyTab = app.tabBars.buttons["History"].firstMatch
        XCTAssertTrue(historyTab.waitForExistence(timeout: 5), "History should appear on the tab bar")
        historyTab.tap()
    }
    
    @MainActor
    func testSearchForACity() throws {
        let searchButton = app.images["magnifyingglass"].firstMatch
        XCTAssertTrue(searchButton.waitForExistence(timeout: 5), "Search button should exist")
        searchButton.tap()

        let searchField = app.searchFields["Type here to search a city"].firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should appear")
        
        searchField.tap()
        searchField.typeText("Miami")
        app.typeText("\r")
    }
    
    @MainActor
    func testSearchCityAndRemoveFromHistory() throws {
        let searchButton = app.images["magnifyingglass"].firstMatch
        XCTAssertTrue(searchButton.waitForExistence(timeout: 5), "Search button should exist")
        searchButton.tap()

        let searchField = app.searchFields["Type here to search a city"].firstMatch
        XCTAssertTrue(searchField.waitForExistence(timeout: 5), "Search field should appear")
        
        searchField.tap()
        searchField.typeText("London")
        app.typeText("\r")
        
        
        let historyTab = app.tabBars.buttons["History"].firstMatch
        XCTAssertTrue(historyTab.waitForExistence(timeout: 5), "History should appear on the tab bar")
        historyTab.tap()
        
        
        let londonAppears = app.buttons["London"].firstMatch
        XCTAssertTrue(londonAppears.waitForExistence(timeout: 5), "London should appear")
        
        londonAppears.swipeLeft()

        app.buttons["Delete"].firstMatch.tap()
    }
    
    @MainActor
    func testAddCityToFavorite() throws {
        let favButton = app.buttons["star"].firstMatch
        XCTAssertTrue(favButton.waitForExistence(timeout: 5), "The button of empty favorites should appear here")
        favButton.tap()
    }
    
    @MainActor
    func testUnitChange() throws {
        let unitOption = app.buttons["Units"].firstMatch
        XCTAssertTrue(unitOption.waitForExistence(timeout: 5), "The units buttons should be here...")
        unitOption.tap()
        app.otherElements.element(boundBy: 11).tap()
    }
    
    @MainActor
    func testAddThenRemoveFromFavorites() throws {
        let starButton = app.buttons["star"].firstMatch
        XCTAssertTrue(starButton.waitForExistence(timeout: 2))
        starButton.tap()
        
        let favoriteIcon = app.images["star.fill"].firstMatch
        
        app.tabBars.buttons["Favorites"].firstMatch.tap()
        
        let mendozaCell = app.buttons["Mendoza"].firstMatch
        XCTAssertTrue(mendozaCell.waitForExistence(timeout: 3), "Mendoza should appear in favorites")

        mendozaCell.swipeLeft()
        app.staticTexts["Delete"].firstMatch.tap()
    }
}
