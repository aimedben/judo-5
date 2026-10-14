package com.example.ui.components

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CloudDone
import androidx.compose.material.icons.filled.CloudOff
import androidx.compose.material.icons.filled.CloudSync
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.Sync
import androidx.compose.material.icons.filled.Warning
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.sync.SupabaseConfig
import com.example.data.sync.SyncReport
import com.example.ui.theme.JudoGold
import com.example.ui.theme.JudoRed
import com.example.ui.theme.JudoSuccess
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

@Composable
fun QuitSyncDialog(
    pendingCount: Int,
    supabaseConfig: SupabaseConfig,
    isOnline: Boolean,
    isSyncing: Boolean,
    lastSyncReport: SyncReport?,
    onSyncAndQuit: () -> Unit,
    onQuitWithoutSync: () -> Unit,
    onDismiss: () -> Unit
) {
    var showWarningForQuitWithoutSync by remember { mutableStateOf(false) }

    val lastSyncFormatted = if (supabaseConfig.lastSyncTimestamp > 0) {
        val sdf = SimpleDateFormat("dd/MM/yyyy 'à' HH:mm", Locale.FRANCE)
        sdf.format(Date(supabaseConfig.lastSyncTimestamp))
    } else {
        "Aucune synchronisation antérieure"
    }

    if (showWarningForQuitWithoutSync) {
        AlertDialog(
            onDismissRequest = { showWarningForQuitWithoutSync = false },
            icon = {
                Box(
                    modifier = Modifier
                        .size(48.dp)
                        .clip(CircleShape)
                        .background(MaterialTheme.colorScheme.error.copy(alpha = 0.15f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Warning,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.error,
                        modifier = Modifier.size(28.dp)
                    )
                }
            },
            title = {
                Text(
                    text = "Avertissement de sauvegarde",
                    style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.Bold),
                    textAlign = TextAlign.Center
                )
            },
            text = {
                Text(
                    text = "Vous avez $pendingCount modification(s) enregistrée(s) uniquement sur cette tablette.\n\nSi vous quittez sans synchroniser, vos modifications restent en sécurité sur l'appareil, mais ne seront pas répliquées sur Supabase Cloud jusqu'à la prochaine synchronisation.",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        showWarningForQuitWithoutSync = false
                        onQuitWithoutSync()
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error,
                        contentColor = Color.White
                    ),
                    shape = RoundedCornerShape(10.dp),
                    modifier = Modifier.testTag("confirm_quit_without_sync_btn")
                ) {
                    Text("Quitter quand même", fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                OutlinedButton(
                    onClick = { showWarningForQuitWithoutSync = false },
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Text("Annuler")
                }
            }
        )
        return
    }

    AlertDialog(
        onDismissRequest = {
            if (!isSyncing) onDismiss()
        },
        icon = {
            Box(
                modifier = Modifier
                    .size(54.dp)
                    .clip(CircleShape)
                    .background(
                        if (pendingCount > 0) JudoGold.copy(alpha = 0.15f)
                        else JudoSuccess.copy(alpha = 0.15f)
                    ),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = if (pendingCount > 0) Icons.Default.CloudSync else Icons.Default.CloudDone,
                    contentDescription = null,
                    tint = if (pendingCount > 0) JudoGold else JudoSuccess,
                    modifier = Modifier.size(32.dp)
                )
            }
        },
        title = {
            Text(
                text = "Fermeture & Synchronisation",
                style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Bold),
                textAlign = TextAlign.Center
            )
        },
        text = {
            Column(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(12.dp)
            ) {
                // Status Pill: Online / Offline
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clip(RoundedCornerShape(8.dp))
                        .background(
                            if (isOnline) JudoSuccess.copy(alpha = 0.12f)
                            else MaterialTheme.colorScheme.error.copy(alpha = 0.12f)
                        )
                        .padding(horizontal = 12.dp, vertical = 8.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Icon(
                            imageVector = if (isOnline) Icons.Default.CloudDone else Icons.Default.CloudOff,
                            contentDescription = null,
                            tint = if (isOnline) JudoSuccess else MaterialTheme.colorScheme.error,
                            modifier = Modifier.size(18.dp)
                        )
                        Text(
                            text = if (isOnline) "Connexion Internet active" else "Mode Hors-ligne (Tatami)",
                            style = MaterialTheme.typography.bodySmall.copy(
                                fontWeight = FontWeight.SemiBold,
                                color = if (isOnline) JudoSuccess else MaterialTheme.colorScheme.error
                            )
                        )
                    }
                }

                // Summary card
                Surface(
                    shape = RoundedCornerShape(12.dp),
                    color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
                    border = androidx.compose.foundation.BorderStroke(1.dp, MaterialTheme.colorScheme.outlineVariant.copy(alpha = 0.5f))
                ) {
                    Column(
                        modifier = Modifier.padding(14.dp),
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = "Modifications en attente :",
                                style = MaterialTheme.typography.bodyMedium.copy(color = MaterialTheme.colorScheme.onSurfaceVariant)
                            )
                            Text(
                                text = if (pendingCount == 0) "À jour (0)" else "$pendingCount opération(s)",
                                style = MaterialTheme.typography.bodyMedium.copy(
                                    fontWeight = FontWeight.Bold,
                                    color = if (pendingCount == 0) JudoSuccess else JudoGold
                                )
                            )
                        }

                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = "Dernière synchro cloud :",
                                style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.onSurfaceVariant)
                            )
                            Text(
                                text = lastSyncFormatted,
                                style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Medium)
                            )
                        }
                    }
                }

                // Sync in progress animation
                AnimatedVisibility(visible = isSyncing) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(vertical = 8.dp),
                        horizontalAlignment = Alignment.CenterHorizontally,
                        verticalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        CircularProgressIndicator(
                            color = JudoGold,
                            modifier = Modifier.size(32.dp)
                        )
                        Text(
                            text = "Synchronisation Supabase en cours...",
                            style = MaterialTheme.typography.bodySmall.copy(fontWeight = FontWeight.Medium)
                        )
                    }
                }

                // Last sync result message
                if (lastSyncReport != null && !isSyncing) {
                    if (lastSyncReport.isSuccess) {
                        Text(
                            text = "✓ ${lastSyncReport.itemsSent} élément(s) synchronisé(s) avec succès.",
                            style = MaterialTheme.typography.bodySmall.copy(color = JudoSuccess, fontWeight = FontWeight.Bold)
                        )
                    } else if (lastSyncReport.errorMessage != null) {
                        Text(
                            text = "Erreur: ${lastSyncReport.errorMessage}",
                            style = MaterialTheme.typography.bodySmall.copy(color = MaterialTheme.colorScheme.error)
                        )
                    }
                }
            }
        },
        confirmButton = {
            if (supabaseConfig.isConfigured && isOnline) {
                Button(
                    onClick = onSyncAndQuit,
                    enabled = !isSyncing,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = JudoSuccess,
                        contentColor = Color.White
                    ),
                    shape = RoundedCornerShape(10.dp),
                    modifier = Modifier.testTag("sync_and_quit_btn")
                ) {
                    Icon(
                        imageVector = Icons.Default.Sync,
                        contentDescription = null,
                        modifier = Modifier.size(18.dp)
                    )
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(
                        text = if (pendingCount > 0) "Synchroniser et Quitter" else "Vérifier et Quitter",
                        fontWeight = FontWeight.Bold
                    )
                }
            } else {
                Button(
                    onClick = onQuitWithoutSync,
                    colors = ButtonDefaults.buttonColors(
                        containerColor = JudoRed,
                        contentColor = Color.White
                    ),
                    shape = RoundedCornerShape(10.dp),
                    modifier = Modifier.testTag("quit_direct_btn")
                ) {
                    Text("Quitter la session", fontWeight = FontWeight.Bold)
                }
            }
        },
        dismissButton = {
            Row(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                if (pendingCount > 0 && supabaseConfig.isConfigured && isOnline) {
                    TextButton(
                        onClick = { showWarningForQuitWithoutSync = true },
                        enabled = !isSyncing,
                        modifier = Modifier.testTag("quit_without_sync_btn")
                    ) {
                        Text(
                            text = "Quitter sans sync",
                            color = MaterialTheme.colorScheme.error,
                            style = MaterialTheme.typography.labelMedium
                        )
                    }
                }

                OutlinedButton(
                    onClick = onDismiss,
                    enabled = !isSyncing,
                    shape = RoundedCornerShape(10.dp),
                    modifier = Modifier.testTag("cancel_quit_dialog_btn")
                ) {
                    Text("Continuer")
                }
            }
        }
    )
}
