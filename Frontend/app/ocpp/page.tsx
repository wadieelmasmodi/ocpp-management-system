"use client";

import { AppShell } from "@/components/layout/AppShell";
import { OcppLogViewer } from "@/components/ocpp/OcppLogViewer";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { TerminalSquare } from "lucide-react";
import Link from "next/link";
import { Button } from "@/components/ui/button";

export default function OcppManagementPage() {
  return (
    <AppShell>
      <div className="mb-6 space-y-4">
        <div className="flex justify-between items-center">
          <div>
            <h1 className="text-2xl font-bold tracking-tight">OCPP Protocol Management</h1>
            <p className="text-muted-foreground">Monitor WebSocket traffic and issue global remote commands.</p>
          </div>
          <Link href="/chargers">
            <Button variant="outline">
               Go to Charger Details for specific commands
            </Button>
          </Link>
        </div>
      </div>

      <Alert className="mb-6 bg-blue-500/10 border-blue-500/20 text-blue-600 dark:text-blue-400">
        <TerminalSquare className="h-4 w-4" />
        <AlertTitle>Developer View</AlertTitle>
        <AlertDescription>
          This tab provides direct visibility into the OCPP 1.6-J JSON messages traveling over WebSocket. 
          Use the Charger Detail pages to send specific RemoteStart, RemoteStop, and TriggerMessage commands.
        </AlertDescription>
      </Alert>

      <OcppLogViewer />
    </AppShell>
  );
}
