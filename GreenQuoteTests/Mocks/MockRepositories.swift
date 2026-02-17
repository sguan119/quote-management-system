//
//  MockRepositories.swift
//  GreenQuoteTests
//

import Foundation
import CoreData
@testable import GreenQuote

// MARK: - Mock Settings Repository

class MockSettingsRepository: SettingsRepositoryProtocol {
    var mockSettings: Settings?
    var saveCallCount = 0
    var shouldThrowError = false

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchOrCreate() throws -> Settings {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }

        if let settings = mockSettings {
            return settings
        }

        // Create default settings
        let settings = Settings(context: context)
        settings.commercialCadPerSf = NSDecimalNumber(decimal: 0.45)
        settings.standardCadPerSf = NSDecimalNumber(decimal: 0.58)
        settings.specialCadPerSf = NSDecimalNumber(decimal: 0.68)
        // OQ-D11 fix: Set default special labour rate
        settings.specialLabourCadPerHour = NSDecimalNumber(decimal: 65.00)
        // OQ-D14 fix: Set default max retries
        settings.maxSyncRetries = 5
        mockSettings = settings
        return settings
    }

    func save() throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        saveCallCount += 1
    }

    // Token management
    func saveEncryptedAccessToken(_ token: String) throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
    }

    func getDecryptedAccessToken() throws -> String? {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
        return nil
    }

    func saveEncryptedRefreshToken(_ token: String) throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
    }

    func getDecryptedRefreshToken() throws -> String? {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
        return nil
    }

    func saveEncryptedClientSecret(_ secret: String) throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
    }

    func getDecryptedClientSecret() throws -> String? {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
        return nil
    }

    func saveTokenExpiry(_ expiry: Date) throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
    }

    func getTokenExpiry() throws -> Date? {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
        return nil
    }

    func saveRealmId(_ realmId: String) throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
    }

    func getRealmId() throws -> String? {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
        return nil
    }

    func clearTokens() throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
    }

    // QuickBooks management
    func saveQboCustomerTypes(_ customerTypes: [QBOCustomerType]) throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
    }

    func getQboCustomerTypes() throws -> [String: String] {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
        return [:]
    }

    func findQboCustomerTypeId(byName name: String) throws -> String? {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
        return nil
    }

    func saveQboWallPaintingId(_ wallPaintingId: String) throws {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
    }

    func getQboWallPaintingId() throws -> String? {
        if shouldThrowError { throw NSError(domain: "MockError", code: 1, userInfo: nil) }
        return nil
    }
}

// MARK: - Mock Paint Item Repository

class MockPaintItemRepository: PaintItemRepositoryProtocol {
    var mockItems: [PaintItem] = []
    var saveCallCount = 0
    var shouldThrowError = false

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() throws -> [PaintItem] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockItems
    }

    func fetch(by id: UUID) throws -> PaintItem? {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockItems.first { $0.id == id }
    }

    func fetchByType(_ type: String) throws -> [PaintItem] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockItems.filter { $0.paintType == type }
    }

    func fetchByWallOrCeiling(_ wallOrCeiling: String) throws -> [PaintItem] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockItems.filter { $0.wallOrCeiling == wallOrCeiling }
    }

    func create() -> PaintItem {
        let item = PaintItem(context: context)
        item.id = UUID()
        mockItems.append(item)
        return item
    }

    func delete(_ item: PaintItem) {
        mockItems.removeAll { $0.id == item.id }
    }

    func save() throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        saveCallCount += 1
    }
}

// MARK: - Mock Room Repository

class MockRoomRepository: RoomRepositoryProtocol {
    var mockRooms: [Room] = []
    var saveCallCount = 0
    var shouldThrowError = false

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll(for customer: Customer) throws -> [Room] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockRooms.filter { $0.customer?.id == customer.id }
    }

    func fetch(by id: UUID) throws -> Room? {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockRooms.first { $0.id == id }
    }

    func create(for customer: Customer) -> Room {
        let room = Room(context: context)
        room.id = UUID()
        room.customer = customer
        room.createdAt = Date()
        room.primerCoats = 1
        room.finishCoats = 2
        mockRooms.append(room)
        return room
    }

    func delete(_ room: Room) {
        mockRooms.removeAll { $0.id == room.id }
    }

    func save() throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        saveCallCount += 1
    }
}

// MARK: - Mock Customer Repository

class MockCustomerRepository: CustomerRepositoryProtocol {
    var mockCustomers: [Customer] = []
    var saveCallCount = 0
    var shouldThrowError = false

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() throws -> [Customer] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockCustomers
    }

    func fetch(by id: UUID) throws -> Customer? {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockCustomers.first { $0.id == id }
    }

    func fetchByEmail(_ email: String) throws -> Customer? {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockCustomers.first { $0.email == email }
    }

    func create() -> Customer {
        let customer = Customer(context: context)
        customer.id = UUID()
        customer.createdAt = Date()
        mockCustomers.append(customer)
        return customer
    }

    func delete(_ customer: Customer) {
        mockCustomers.removeAll { $0.id == customer.id }
    }

    func save() throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        saveCallCount += 1
    }
}

// MARK: - Mock Sync Job Repository

class MockSyncJobRepository: SyncJobRepositoryProtocol {
    var mockJobs: [SyncJob] = []
    var saveCallCount = 0
    var shouldThrowError = false

    private let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func fetchAll() throws -> [SyncJob] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockJobs
    }

    func fetchPending() throws -> [SyncJob] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockJobs.filter { $0.state == "Queued" || $0.state == "Running" }
    }

    func fetchByCustomer(_ customerId: UUID) throws -> [SyncJob] {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        return mockJobs.filter { $0.customerId == customerId }
    }

    func create(type: SyncJobType, customerId: UUID, payload: Data?) -> SyncJob {
        let job = SyncJob(context: context)
        job.id = UUID()
        job.type = type.rawValue
        job.customerId = customerId
        job.payload = payload
        job.state = "Queued"
        job.retryCount = 0
        job.createdAt = Date()
        job.lastUpdatedAt = Date()
        mockJobs.append(job)
        return job
    }

    func updateState(_ job: SyncJob, to state: String, error: String?) {
        job.state = state
        job.errorMessage = error
        job.lastUpdatedAt = Date()
    }

    func scheduleNextRun(_ job: SyncJob, retryCount: Int, maxRetries: Int16) {
        if retryCount >= Int(maxRetries) {
            updateState(job, to: "Failed", error: "Maximum retries exceeded (\(maxRetries))")
            return
        }
        job.retryCount = Int16(retryCount)
        job.state = "Queued"
        job.lastUpdatedAt = Date()
    }

    func delete(_ job: SyncJob) {
        mockJobs.removeAll { $0.id == job.id }
    }

    func clearAll() throws -> Int {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        let count = mockJobs.count
        mockJobs.removeAll()
        return count
    }

    func save() throws {
        if shouldThrowError {
            throw NSError(domain: "MockError", code: 1, userInfo: nil)
        }
        saveCallCount += 1
    }
}

// MARK: - Test Helpers

class TestHelpers {
    static var testContext: NSManagedObjectContext {
        let container = NSPersistentContainer(name: "GreenQuote")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]

        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load in-memory store: \(error)")
            }
        }

        return container.viewContext
    }

    static func createSampleCustomer(in context: NSManagedObjectContext) -> Customer {
        let customer = Customer(context: context)
        customer.id = UUID()
        customer.firstName = "John"
        customer.lastName = "Doe"
        customer.email = "john.doe@example.com"
        customer.mobile = "555-1234"
        customer.address = "123 Main St"
        customer.city = "Vancouver"
        customer.province = "BC"
        customer.postal = "V5K 0A1"
        customer.country = "Canada"
        customer.customerType = "Home Owner"
        customer.createdAt = Date()
        return customer
    }

    static func createSampleRoom(in context: NSManagedObjectContext, for customer: Customer) -> Room {
        let room = Room(context: context)
        room.id = UUID()
        room.name = "Living Room"
        room.lengthFt = 12
        room.widthFt = 10
        room.heightFt = 8
        room.primerCoats = 1
        room.finishCoats = 2
        room.paintCeiling = false
        room.customer = customer
        room.createdAt = Date()
        return room
    }

    static func createSamplePaintItem(in context: NSManagedObjectContext, finish: String, type: String, wallOrCeiling: String) -> PaintItem {
        let item = PaintItem(context: context)
        item.id = UUID()
        item.finish = finish
        item.paintType = type
        item.wallOrCeiling = wallOrCeiling
        item.coverageSf = NSDecimalNumber(value: 350)
        item.pricePerGallon = NSDecimalNumber(value: 45.99)
        return item
    }
}
