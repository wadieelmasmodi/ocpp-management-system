# Test Cases - Open-Source OCPP CMS

This document contains all test cases to verify CMS functionality manually.

## How to Use

Run `npm run dev` to start the server, then test each case using cURL, Postman, or your preferred API client.

---

## OCPP Server Tests

- [ ] **TC-001**: Verify OCPP server starts on port 9220
  - Expected: Server starts without errors
  - Check: Console shows "OCPP server listening on port 9220"

- [ ] **TC-002**: OCPP server rejects unknown charger
  - Step: Attempt WebSocket connection with unregistered charger ID
  - Expected: Connection rejected/terminated
  - Check: Server logs "Charger {id} not found in database"

- [ ] **TC-003**: OCPP server accepts registered charger
  - Step: Connect with registered charger ID
  - Expected: Connection accepted, charger status set to "active"
  - Check: Server logs "New connection from charger"

- [ ] **TC-004**: BootNotification returns Accepted
  - Step: Charger sends BootNotification message
  - Expected: BootNotification.conf with status="Accepted", interval=300
  - Check: Response logs show accepted status

- [ ] **TC-005**: BootNotification returns Rejected
  - Step: Connect with disabled/deleted charger
  - Expected: BootNotification.conf with status="Rejected"
  - Check: Server logs rejection reason

- [ ] **TC-006**: Heartbeat updates charger timestamp
  - Step: Send Heartbeat messages every 30 seconds
  - Expected: `last_heartbeat` field updated in database
  - Check: Verify via `/api/chargers/{id}/status`

- [ ] **TC-007**: Heartbeat offline monitor marks charger offline
  - Step: Stop sending heartbeats for >60 seconds
  - Expected: Console warning about offline charger
  - Check: Server logs warning about offline status

- [ ] **TC-008**: Authorize accepts valid RFID tag
  - Step: Create RFID tag in `/api/rfid`, send Authorize with that tag
  - Expected: Authorize.conf with idTagInfo.status="Accepted"
  - Check: Server logs "Authorize accepted: {tag}"

- [ ] **TC-009**: Authorize rejects unknown RFID tag
  - Step: Send Authorize with non-existent tag
  - Expected: Authorize.conf with idTagInfo.status="Invalid"
  - Check: Server logs rejection

- [ ] **TC-010**: Authorize rejects inactive RFID tag
  - Step: Deactivate a tag, send Authorize
  - Expected: Authorize.conf with idTagInfo.status="Invalid"
  - Check: Server logs rejection

- [ ] **TC-011**: StartTransaction creates RfidSession (post-paid)
  - Step: Send StartTransaction with valid RFID tag
  - Expected: RfidSession created, transactionId returned
  - Check: `GET /api/transactions/rfid/{id}` shows session with status="charging"

- [ ] **TC-012**: StartTransaction creates basic Transaction
  - Step: Send StartTransaction without RFID (or system tag)
  - Expected: Transaction created, transactionId returned
  - Check: `GET /api/transactions/{id}` shows session

- [ ] **TC-013**: StartTransaction rejects (no valid authorization)
  - Step: Send StartTransaction with invalid/no RFID tag
  - Expected: StartTransaction.conf with idTagInfo.status="Invalid", transactionId=0
  - Check: No session created

- [ ] **TC-014**: MeterValues logged for RfidSession
  - Step: During charging, send MeterValues
  - Expected: RfidSession.energyConsumed field updated
  - Check: Verify energy values increase over time

- [ ] **TC-015**: MeterValues logged for basic Transaction
  - Step: During charging, send MeterValues
  - Expected: Transaction.energyConsumed field updated
  - Check: Verify via API

- [ ] **TC-016**: StopTransaction closes RfidSession
  - Step: Swipe RFID card again, send StopTransaction
  - Expected: Session status="completed", amountDue calculated
  - Check: `GET /api/transactions/rfid/{id}` shows final energy and amount

- [ ] **TC-017**: StopTransaction calculates amount correctly
  - Step: Stop with meterStop = 5000 Wh, start was 1000 Wh, rate = Rs 10/kWh
  - Expected: amountDue = (4000/1000)*10*100 = 4000 paise = Rs 40
  - Check: Verify calculation is correct

- [ ] **TC-018**: StopTransaction closes basic Transaction
  - Step: Send StopTransaction for basic session
  - Expected: Transaction status="completed"
  - Check: `GET /api/transactions/{id}` shows completed status

- [ ] **TC-019**: StatusNotification updates connector status
  - Step: Send StatusNotification with status="Available"
  - Expected: Connector status updated to "Available"
  - Check: `GET /api/connectors` reflects new status

- [ ] **TC-020**: StatusNotification logs fault
  - Step: Send StatusNotification with errorCode
  - Expected: Error logged in server
  - Check: Server logs fault notification

---

## REST API - Stations Tests

- [ ] **TC-021**: GET /api/stations returns all stations
  - Step: Call endpoint without filters
  - Expected: Array of stations with chargers included

- [ ] **TC-022**: GET /api/stations/:id returns specific station
  - Step: Call with valid station ID
  - Expected: Station details with all chargers

- [ ] **TC-023**: GET /api/stations/:id returns 404 for invalid ID
  - Step: Call with non-existent station ID
  - Expected: 404 response with error message

- [ ] **TC-024**: GET /api/stations/:id/chargers returns station chargers
  - Step: Call endpoint for a specific station
  - Expected: Only chargers belonging to that station

- [ ] **TC-025**: POST /api/stations creates new station
  - Step: Send valid station data with auth token
  - Expected: 201 response with created station

- [ ] **TC-026**: POST /api/stations validates required fields
  - Step: Send missing required fields
  - Expected: 400 response with validation error

- [ ] **TC-027**: PUT /api/stations/:id updates station
  - Step: Send valid update data with admin token
  - Expected: Updated station returned

- [ ] **TC-028**: PUT /api/stations/:id rejects unauthenticated user
  - Step: Call update without auth header
  - Expected: 401 response

- [ ] **TC-029**: DELETE /api/stations/:id deletes station
  - Step: Call with admin token
  - Expected: Success message returned

---

## REST API - Chargers Tests

- [ ] **TC-030**: GET /api/chargers returns all chargers
  - Step: Call endpoint
  - Expected: Array of all chargers with station and connectors

- [ ] **TC-031**: GET /api/chargers/:id returns specific charger
  - Step: Call with valid charger ID
  - Expected: Charger details with connectors included

- [ ] **TC-032**: GET /api/chargers/:id/status shows real-time status
  - Step: Call endpoint
  - Expected: Status, isOnline, lastHeartbeat, connectors

- [ ] **TC-033**: POST /api/chargers creates new charger
  - Step: Send valid charger data
  - Expected: 201 response, charger created in DB

- [ ] **TC-034**: POST /api/chargers rejects duplicate name
  - Step: Create charger with existing name
  - Expected: 400 response "Charger name already exists"

- [ ] **TC-035**: PUT /api/chargers/:id updates charger
  - Step: Send valid update data
  - Expected: Updated charger returned

- [ ] **TC-036**: DELETE /api/chargers/:id deletes charger
  - Step: Call with valid charger ID
  - Expected: Success message, charger removed from DB

- [ ] **TC-037**: POST /api/chargers/connectors bulk creates connectors
  - Step: Send array of connector objects
  - Expected: 201 response with created connectors

---

## REST API - Connectors Tests

- [ ] **TC-038**: GET /api/connectors returns all connectors
  - Step: Call endpoint
  - Expected: Array of all connectors

- [ ] **TC-039**: GET /api/connectors/:id returns specific connector
  - Step: Call with valid connector ID
  - Expected: Connector details with charger info

- [ ] **TC-040**: POST /api/connectors creates new connector
  - Step: Send valid connector data
  - Expected: 201 response, connector created

- [ ] **TC-041**: POST /api/connectors rejects invalid charger_id
  - Step: Create connector with non-existent charger
  - Expected: 400 response "Charger not found"

- [ ] **TC-042**: PUT /api/connectors/:id updates connector
  - Step: Send valid update data
  - Expected: Updated connector returned

- [ ] **TC-043**: DELETE /api/connectors/:id deletes connector
  - Step: Call with valid connector ID
  - Expected: Success message, connector removed from DB

---

## REST API - RFID Tests

- [ ] **TC-044**: GET /api/rfid returns all tags
  - Step: Call endpoint
  - Expected: Array of all RFID tags

- [ ] **TC-045**: GET /api/rfid filters by status
  - Step: Call with `?active=true`
  - Expected: Only active tags returned

- [ ] **TC-046**: GET /api/rfid/:id returns specific tag
  - Step: Call with valid tag ID
  - Expected: Tag details with user info

- [ ] **TC-047**: POST /api/rfid creates new tag
  - Step: Send valid tag data
  - Expected: 201 response, tag created in DB

- [ ] **TC-048**: POST /api/rfid rejects duplicate tag
  - Step: Create tag with existing rfid_tag
  - Expected: 400 response "RFID tag already exists"

- [ ] **TC-049**: PUT /api/rfid/:id updates tag
  - Step: Send valid update data
  - Expected: Updated tag returned

- [ ] **TC-050**: PATCH /api/rfid/:id/toggle activates tag
  - Step: Call with `?active=true`
  - Expected: Tag status updated to active

- [ ] **TC-051**: PATCH /api/rfid/:id/toggle deactivates tag
  - Step: Call with `?active=false`
  - Expected: Tag status updated to false

- [ ] **TC-052**: DELETE /api/rfid/:id deletes tag
  - Step: Call with valid tag ID
  - Expected: Success message, tag removed from DB

---

## REST API - Transactions Tests

- [ ] **TC-053**: GET /api/transactions returns paginated list
  - Step: Call without filters
  - Expected: First page with 50 items, pagination metadata

- [ ] **TC-054**: GET /api/transactions/:id returns specific transaction
  - Step: Call with valid transaction ID
  - Expected: Transaction details with charger and station info

- [ ] **TC-055**: GET /api/transactions/:id returns 404 for invalid ID
  - Step: Call with non-existent transaction ID
  - Expected: 404 response

- [ ] **TC-056**: GET /api/transactions/active returns charging sessions
  - Step: Call endpoint
  - Expected: Array of active transactions and rfidSessions

- [ ] **TC-057**: GET /api/transactions/charger/:chargerName returns charger transactions
  - Step: Call with valid charger name
  - Expected: All transactions for that charger

- [ ] **TC-058**: GET /api/transactions/charger/:chargerName returns empty for no data
  - Step: Call with charger that has no transactions
  - Expected: Empty array returned

- [ ] **TC-059**: GET /api/transactions/stats returns statistics
  - Step: Call with admin token
  - Expected: Count, energy sums, completed counts

- [ ] **TC-060**: GET /api/transactions/rfid/:id returns RfidSession
  - Step: Call with valid RfidSession ID
  - Expected: Session details with user and charger info

---

## REST API - OCPP Remote Control Tests

- [ ] **TC-061**: POST /api/ocpp/remote-start starts charging
  - Step: Send with chargerId, connectorId, idTag
  - Expected: OCPP request sent, response status="Accepted"

- [ ] **TC-062**: POST /api/ocpp/remote-start validates required fields
  - Step: Send missing chargerId or connectorId
  - Expected: 400 response with error message

- [ ] **TC-063**: POST /api/ocpp/remote-start rejects offline charger
  - Step: Call with offline charger ID
  - Expected: Error "Charger not connected"

- [ ] **TC-064**: POST /api/ocpp/remote-stop stops charging
  - Step: Send with chargerId, transactionId
  - Expected: OCPP request sent, response status="Accepted"

- [ ] **TC-065**: POST /api/ocpp/remote-stop validates required fields
  - Step: Send missing chargerId or transactionId
  - Expected: 400 response with error message

- [ ] **TC-066**: POST /api/ocpp/get-configuration returns config
  - Step: Send chargerId, optional key
  - Expected: Configuration values returned

- [ ] **TC-067**: POST /api/ocpp/set-configuration updates config
  - Step: Send chargerId, configurationKey array
  - Expected: Update request sent, response status="Accepted"

- [ ] **TC-068**: POST /api/ocpp/reset performs soft reset
  - Step: Send chargerId, type="Soft"
  - Expected: OCPP request sent, response status="Accepted"

- [ ] **TC-069**: POST /api/ocpp/reset performs hard reset
  - Step: Send chargerId, type="Hard"
  - Expected: OCPP request sent, response status="Accepted"

- [ ] **TC-070**: POST /api/ocpp/reset validates type
  - Step: Send invalid type (not "Soft" or "Hard")
  - Expected: 400 response with validation error

- [ ] **TC-071**: POST /api/ocpp/unlock unlocks connector
  - Step: Send chargerId, connectorId
  - Expected: OCPP request sent, response status="Accepted"

- [ ] **TC-072**: POST /api/ocpp/trigger-message requests status
  - Step: Send chargerId, optional connectorId
  - Expected: OCPP request sent, charger responds with StatusNotification

- [ ] **TC-073**: GET /api/ocpp/connected returns connected chargers
  - Step: Call endpoint
  - Expected: Array of currently connected charger IDs

---

## REST API - Dashboard Tests

- [ ] **TC-074**: GET /api/dashboard/overview returns metrics
  - Step: Call endpoint
  - Expected: Total stations, chargers, online/offline counts, active sessions, energy today

- [ ] **TC-075**: GET /api/dashboard/overview calculates correctly
  - Step: Verify counts match database
  - Expected: Numbers are accurate

- [ ] **TC-076**: GET /api/dashboard/live-sessions returns active sessions
  - Step: Call endpoint
  - Expected: Array of currently charging sessions

- [ ] **TC-077**: GET /api/dashboard/distribution returns connector status
  - Step: Call endpoint
  - Expected: Available, charging, faulted counts

---

## OCPP Logs WebSocket Tests

- [ ] **TC-078**: WebSocket connection accepted
  - Step: Connect to `ws://localhost:3001/ocpp-logs`
  - Expected: Welcome message received

- [ ] **TC-079**: WebSocket receives connection message
  - Step: Connect new client
  - Expected: Client count increases

- [ ] **TC-080**: WebSocket receives history
  - Step: New client connects
  - Expected: Recent 50 OCPP logs sent

- [ ] **TC-081**: WebSocket receives live logs
  - Step: Generate OCPP traffic (connect charger, send messages)
  - Expected: New log entries broadcasted

- [ ] **TC-082**: WebSocket client disconnects
  - Step: Close connection
  - Expected: Client count decreases, disconnection logged

---

## Integration Tests

- [ ] **TC-083**: Full charging session flow (RFID)
  - Step: Create RFID tag → Connect charger → Swipe card → Verify Authorize → StartTx → MeterValues → StopTx
  - Expected: Complete RfidSession with amountDue

- [ ] **TC-084**: Full charging session flow (basic)
  - Step: Create station/charger → Manual StartTx via API → MeterValues → StopTx via API
  - Expected: Complete Transaction with energy consumed

- [ ] **TC-085**: Remote start to offline charger
  - Step: Wait for charger to go offline → Send remote-start
  - Expected: Error response, no session created

- [ ] **TC-086**: Dashboard reflects live changes
  - Step: Start charging session → Call /api/dashboard/live-sessions
  - Expected: New session appears in live sessions

---

## Test Summary

Use this checklist to verify all functionality before deploying:

**Critical Path Tests (Must Pass):** TC-001 through TC-020
**API Tests (Must Pass):** TC-021 through TC-040, TC-044 through TC-052
**Remote Control Tests (Must Pass):** TC-061 through TC-073
**Dashboard Tests (Must Pass):** TC-074 through TC-077
**Security Tests (Must Pass):** TC-028 (auth required)

Total Test Cases: 82
