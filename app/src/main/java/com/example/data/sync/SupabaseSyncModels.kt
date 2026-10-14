package com.example.data.sync

data class SupabaseConfig(
    val url: String = "",
    val anonKey: String = "",
    val isAutoSyncEnabled: Boolean = true,
    val isDaily22hSyncEnabled: Boolean = true,
    val lastSyncTimestamp: Long = 0L,
    val lastSyncStatus: String = "NON_CONFIGURE"
) {
    val isConfigured: Boolean
        get() = url.isNotBlank() && anonKey.isNotBlank() && url.startsWith("https://")
}

data class SyncReport(
    val isSuccess: Boolean,
    val itemsSent: Int = 0,
    val itemsReceived: Int = 0,
    val conflictsResolved: Int = 0,
    val pendingRemaining: Int = 0,
    val errorMessage: String? = null,
    val timestamp: Long = System.currentTimeMillis()
)

data class BackupMetadata(
    val appVersion: String = "1.0",
    val schemaVersion: Int = 2,
    val clubName: String = "Judo Club Seddouk",
    val exportedAt: String,
    val totalMembers: Int,
    val totalAttendances: Int,
    val totalCategories: Int,
    val totalCoaches: Int,
    val totalScheduledSessions: Int,
    val totalPastSessions: Int
)
