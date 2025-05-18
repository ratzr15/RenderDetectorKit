# RenderMetricKit

Create a XCFramework to measure the AppHangs in iOS App


## What is a AppHang

**App Hang** occurs when an **iOS application's main thread becomes unresponsive for a significant period (** > 250ms**)**. This means the app is unable to process user input, update its UI, or respond to system events in a timely manner. From the user's perspective, the app appears frozen, leading to a frustrating experience and potentially causing them to force-quit the application.

## Available Solution

**MetricKit:**

- **Concept:** A powerful Apple framework to collect on-device performance and diagnostic data.
- **Implementation:**
  - Adopt `MXMetricManagerSubscriber` and register to receive daily aggregated metrics.
  - MetricKit provides `MXAppRunTimeMetric` which includes `cumulativeForegroundTime` and `cumulativeBackgroundTime`. While not a direct hang measure, significant deviations or low foreground time despite user activity could be an indirect clue.
  - More importantly, MetricKit delivers `MXHangDiagnostic` payloads. These are generated when the system detects a hang of significant duration (typically a few seconds). The payload includes a call stack tree (`MXCallStackTree`) showing the state of the main thread during the hang.
- **Pros:** System-level detection. Provides detailed call stack information. Aggregated and anonymized.
- **Cons:** Data is delivered periodically (e.g., once a day). Requires iOS 13+ (for hang diagnostics).


## Proposed Solution

- **Concept:** RenderMetricKit aims to provide a comprehensive SDK to combat & measure AppHangs
- **Goals:**
  - Create `RenderMetricKit` and distribute to SPM
  - Detect
        - `AppHangs` and show banner to developers in Debug mode during development.
        - `Linters` custom lint rules to avoid non performant code.
  - Log
        - `Collect` save the slow screens per page tag/ route
        - `Record` log the duration per screen as an average time per screen.
  - Visualize
        - `Dashboard` AppHangs per project and AppHangs per screen.


## Installation

To install this package, import `url` through SPM


## Usage Example
```
@main
struct YourAppNameApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .overlay(alignment: .top) {
                    HangBannerView()
                }
                .onAppear {
                    HangMonitor.shared.startMonitoring()
                }
        }
    }
}
```

## Example
```
struct ContentView: View {
    var body: some View {
        NavigationView {
            VStack {
                NavigationLink("Go to Screen 2") {
                    ScreenTwoView()
                }
                Button("Simulate Hang") {
                    // Simulate a 300ms hang
                    Thread.sleep(forTimeInterval: 0.3)
                    print("Hang simulated")
                }
            }
            .navigationTitle("Screen 1")
        }
    }
}

struct ScreenTwoView: View {
    var body: some View {
        VStack {
            Text("This is Screen 2")
            Button("Simulate Another Hang") {
                // Simulate a 150ms hang
                Thread.sleep(forTimeInterval: 0.15)
                print("Another hang simulated")
            }
        }
        .navigationTitle("Screen 2")
    }
}```
