@testable import Graffiti_Backgrounds
import Reachability
import XCTest

final class HelpTests: XCTestCase {
    func testHelpOnMenuClickOpensURL() {
        // mocks
        let workspace = MockWorkspace()
        let env = AppTestEnvironment(workspace: workspace)
        env.inject()

        // sut
        env.statusItem.menu?.click(at: AppMenu.Order.help.rawValue)

        // test
        let url = workspace.invocations.find(MockWorkspace.open1.name).first?
            .parameter(for: MockWorkspace.open1.params.url) as? URL
        XCTAssertEqual(url?.absoluteString, "http://github.com/larromba/graffiti-backgrounds")
    }
}
