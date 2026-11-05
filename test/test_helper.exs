# Keep the suite hermetic: QlikMCP.Config falls back to these variables, so a
# developer shell with real Qlik credentials would otherwise leak into tests.
Enum.each(~w(QLIK_API_KEY QLIK_TENANT_URL QLIK_MAX_ROWS), &System.delete_env/1)

ExUnit.start()

# Load test support modules
Code.require_file("support/mocks.ex", __DIR__)
Code.require_file("support/fixtures.ex", __DIR__)
