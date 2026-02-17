# Quote Estimator

A professional iPad application for managing customer quotes and estimates with external accounting system integration.

> **Note**: This is a generic, open-source version of a commercial project. All company-specific information, branding, and sensitive business data have been removed or replaced with generic examples.

## Overview

Quote Estimator demonstrates a complete iOS/iPad application built with SwiftUI and CoreData, featuring:

- **MVVM Architecture** with Repository Pattern
- **CoreData** for local persistence
- **OAuth 2.0 PKCE** authentication flow
- **Background sync** with task queue management
- **Responsive UI** optimized for iPad with golden ratio layouts
- **Comprehensive test coverage** (unit + UI tests)

## Features

### Core Functionality

- **Customer Management**: Create, edit, and organize customer information
- **Room/Project Estimation**: Configure dimensions, materials, and pricing
- **Quote Generation**: Generate detailed estimates with itemized breakdowns
- **External System Integration**: Sync customers and estimates to external accounting systems via REST API
- **Background Sync Queue**: Automatic retry mechanism with state management
- **Offline Support**: Work offline and sync when network is available

### Technical Highlights

- Modern Swift Concurrency (async/await)
- CoreData with 5 entities (Customer, Room, PaintItem, Settings, SyncJob)
- Encrypted credential storage using Keychain
- OAuth 2.0 with PKCE (Proof Key for Code Exchange)
- Local HTTP server for OAuth callbacks
- Network monitoring and automatic reconnection
- Comprehensive data validation

## Architecture

The application follows **MVVM + Repository** pattern with clear separation of concerns:

```
Views → ViewModels → Repositories → CoreData/Network
```

### Key Components

- **Views**: SwiftUI views (CustomerListView, RoomEditorView, etc.)
- **ViewModels**: Business logic and state management
- **Repositories**: Data access abstraction (CustomerRepository, RoomRepository)
- **Services**: Network (ERPClient), Authentication (ERPAuthService), Sync (SyncQueue)
- **Models**: CoreData entities

For detailed architecture documentation, see [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md).

## Tech Stack

- **Language**: Swift 5.9+
- **UI Framework**: SwiftUI
- **Persistence**: CoreData
- **Networking**: URLSession with async/await
- **Authentication**: OAuth 2.0 PKCE
- **Security**: Keychain, AES encryption
- **Testing**: XCTest (Unit + UI)
- **Platform**: iOS 16+, iPadOS 16+

## Project Structure

```
QuoteEstimator/
├── docs/                    # Documentation
│   ├── ARCHITECTURE.md      # Architecture & code guidelines
│   ├── DATA_CONTRACT.md     # Data models & API contracts
│   ├── PRD.md              # Product requirements
│   └── UI_SPEC.md          # UI specifications
├── GreenQuoteTests/         # Unit tests
├── GreenQuoteUITests/       # UI tests
└── [Source files would be in main directory]
```

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 16.0+ / iPadOS 16.0+
- Apple Developer account (for device testing)

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/quote-estimator.git
   cd quote-estimator
   ```

2. Open the project:
   ```bash
   open QuoteEstimator.xcodeproj
   ```

3. Build and run:
   - Select target: `QuoteEstimator`
   - Choose simulator or device
   - Press `Cmd + R`

### Configuration

To connect to an external accounting system:

1. Obtain OAuth credentials from your accounting system provider
2. Navigate to **Settings** → **OAuth Configuration**
3. Enter:
   - Client ID
   - Client Secret
   - Redirect URI (e.g., `http://localhost:8080/callback`)
4. Select environment (Sandbox/Production)
5. Click "Sign in"

## Usage Examples

### Creating a Customer

1. Open the app
2. Tap "Create Customer"
3. Fill in customer details (name, email, phone, address)
4. Save

### Adding a Project/Room Estimate

1. Select a customer
2. Go to "Rooms" tab
3. Add a new room
4. Configure:
   - Dimensions (length × width × height)
   - Material selection
   - Number of coats
   - Project type
   - Optional: ceiling, special labor, discounts
5. View real-time price calculation
6. Save

### Syncing to External System

1. Navigate to "Estimate" tab
2. Review the generated quote description
3. Ensure customer has valid email
4. Tap "Create/Update Customer & Estimate"
5. Monitor sync status in "Recent Jobs" panel

## Testing

### Run Unit Tests

```bash
xcodebuild test -scheme QuoteEstimator -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch)'
```

### Run UI Tests

```bash
xcodebuild test -scheme QuoteEstimatorUITests -destination 'platform=iOS Simulator,name=iPad Pro (12.9-inch)'
```

### Test Coverage

The project includes:
- **Unit Tests**: RoomCalculatorTests, FormattingTests, ValidationTests
- **UI Tests**: End-to-end workflows
- **Mock Objects**: For repository and service layers

## Data Model

### Core Entities

1. **Customer**: Customer information (name, email, address, etc.)
2. **Room**: Project/room details (dimensions, materials, pricing)
3. **PaintItem**: Material catalog (coverage, price, type)
4. **Settings**: App configuration (OAuth, pricing tiers)
5. **SyncJob**: Background sync queue management

See [docs/DATA_CONTRACT.md](docs/DATA_CONTRACT.md) for complete data model documentation.

## API Integration

The app demonstrates integration with external accounting systems via REST API:

- **Authentication**: OAuth 2.0 with PKCE flow
- **Customer Sync**: Create/update customer records
- **Estimate Creation**: Generate itemized quotes
- **Background Queue**: Automatic retry with exponential backoff

Example API implementations can be adapted to work with:
- QuickBooks Online
- Xero
- FreshBooks
- Custom ERP systems

## Security

- OAuth credentials encrypted with AES
- Tokens stored in iOS Keychain
- Sensitive data never logged
- Network requests over HTTPS only
- Input validation on all user data

## Customization

### Adapting for Your Business

1. **Material Types**: Update `PaintItem` entity for your materials/services
2. **Pricing Logic**: Modify `RoomCalculator.swift` for your pricing model
3. **API Integration**: Implement `ERPClient` protocol for your accounting system
4. **UI Customization**: Update Design Tokens in `UI_SPEC.md`

### Example Data

The project includes sample pricing data (marked as **[示例]**):
- Type A: $0.40/ft²
- Type B: $0.50/ft²
- Type C: $0.60/ft²

Replace these with your actual pricing in production.

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

## Documentation

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) - Architecture patterns and code guidelines
- [DATA_CONTRACT.md](docs/DATA_CONTRACT.md) - Data models and API contracts
- [PRD.md](docs/PRD.md) - Product requirements and user stories
- [UI_SPEC.md](docs/UI_SPEC.md) - UI design specifications

## License

[Choose appropriate license - MIT, Apache 2.0, etc.]

## Acknowledgments

This project was developed as a demonstration of modern iOS development practices including:
- MVVM architecture with SwiftUI
- CoreData persistence
- OAuth 2.0 authentication
- Background task management
- Network resilience patterns

---

**Disclaimer**: This is a generic template project. All company names, pricing data, and business logic have been generalized for open-source distribution. Adapt the code to your specific business requirements.
