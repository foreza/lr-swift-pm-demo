# Release Notes

## Initial release
- PMSD-1634 – Create new object for syncing `LRPrivacyManager` data
- PMSD-1745 – Add properties to sync from Privacy Manager
- PMSD-1784 – Change endpoints to v1 and improve error logging
- PMSD-1786 – Rename `PL_lastSyncTime` to `PL_serverConsentTime`
- PMSD-1795 – Stop syncing `auditId` locally
- PMSD-1784 – Add acceptance (UAT) endpoint
- PMSD-1787 – Add support for `gdprMobileConfigVersion`, remove `configVersion`
- PMSD-1640 – Not found is not logged as error, add string description for sync status
- PMSD-1799 – Support additional data for sync and custom identifier
- PMSD-1799 – Add support for `additionalData` and custom `identifyingField`
- PMSD-1808 – Change `lastInteraction` and `gdprMobileConfigVersion` to `Int` to align with Android
- PMSD-1799 – Add `badRequest` error, avoid crash for non serializable  `additionalData`
