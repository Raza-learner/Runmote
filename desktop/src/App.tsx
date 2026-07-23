import { useState, useEffect, useCallback } from "react";
import { invoke } from "@tauri-apps/api/core";
import { listen } from "@tauri-apps/api/event";
import { Button } from "@/components/ui/button";
import {
  Dialog,
  DialogContent,
  DialogHeader,
  DialogTitle,
  DialogDescription,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogContent,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogAction,
  AlertDialogCancel,
} from "@/components/ui/alert-dialog";
import type {
  DaemonStatus,
  PairingInfo,
  AgentInfo,
  UninstallResult,
} from "./types";

function App() {
  const [status, setStatus] = useState<DaemonStatus>({
    running: false,
    pid: null,
  });
  const [loading, setLoading] = useState<"idle" | "starting" | "stopping">(
    "idle",
  );
  const [error, setError] = useState<string | null>(null);

  const [pairing, setPairing] = useState<PairingInfo | null>(null);
  const [pairingLoading, setPairingLoading] = useState(false);
  const [pairingOpen, setPairingOpen] = useState(false);

  const [textCode, setTextCode] = useState<string | null>(null);
  const [textCodeOpen, setTextCodeOpen] = useState(false);

  const [uninstallOpen, setUninstallOpen] = useState(false);
  const [uninstalling, setUninstalling] = useState(false);
  const [uninstallResult, setUninstallResult] =
    useState<UninstallResult | null>(null);
  const [uninstallResultOpen, setUninstallResultOpen] = useState(false);

  const [agents, setAgents] = useState<AgentInfo[]>([]);

  const fetchStatus = useCallback(async () => {
    try {
      const s = await invoke<DaemonStatus>("daemon_status");
      setStatus(s);
    } catch {
      // ignore polling errors
    }
  }, []);

  const fetchAgents = useCallback(async () => {
    try {
      const a = await invoke<AgentInfo[]>("get_agents");
      setAgents(a);
    } catch {
      // ignore
    }
  }, []);

  useEffect(() => {
    fetchStatus();
    fetchAgents();
    const interval = setInterval(fetchStatus, 3000);
    return () => clearInterval(interval);
  }, [fetchStatus, fetchAgents]);

  useEffect(() => {
    const unlistenQR = listen<PairingInfo>("tray:show-qr", (event) => {
      setPairing(event.payload);
      setPairingOpen(true);
    });
    const unlistenText = listen<string>("tray:show-text", (event) => {
      setTextCode(event.payload);
      setTextCodeOpen(true);
    });
    const unlistenUninstall = listen("tray:uninstall", () => {
      setUninstallOpen(true);
    });

    return () => {
      unlistenQR.then((fn) => fn());
      unlistenText.then((fn) => fn());
      unlistenUninstall.then((fn) => fn());
    };
  }, []);

  const handleStart = async () => {
    setLoading("starting");
    setError(null);
    try {
      const s = await invoke<DaemonStatus>("daemon_start");
      setStatus(s);
    } catch (e) {
      setError(String(e));
    } finally {
      setLoading("idle");
    }
  };

  const handleStop = async () => {
    setLoading("stopping");
    setError(null);
    try {
      const s = await invoke<DaemonStatus>("daemon_stop");
      setStatus(s);
    } catch (e) {
      setError(String(e));
    } finally {
      setLoading("idle");
    }
  };

  const handleShowQR = async () => {
    setPairingLoading(true);
    setError(null);
    try {
      const info = await invoke<PairingInfo>("get_pairing_info_cmd");
      setPairing(info);
      setPairingOpen(true);
    } catch (e) {
      setError(String(e));
    } finally {
      setPairingLoading(false);
    }
  };

  const handleUninstall = async () => {
    setUninstalling(true);
    try {
      const result = await invoke<UninstallResult>("daemon_uninstall");
      setStatus({ running: false, pid: null });
      setUninstallResult(result);
      setUninstallOpen(false);
      setUninstallResultOpen(true);
    } catch (e) {
      setError(String(e));
    } finally {
      setUninstalling(false);
    }
  };

  return (
    <div className="min-h-screen bg-background text-foreground flex flex-col items-center justify-center p-8">
      <div className="max-w-sm w-full space-y-6">
        <div className="text-center space-y-2">
          <h1 className="text-3xl font-bold tracking-tight">Runmote</h1>
          <p className="text-muted-foreground text-sm">
            ACP Remote Daemon Controller
          </p>
        </div>

        <div className="flex items-center justify-center gap-2 text-sm">
          <span
            className={`inline-block w-2 h-2 rounded-full ${
              status.running ? "bg-green-500" : "bg-red-500"
            }`}
          />
          <span className="text-muted-foreground">
            {status.running
              ? `Running${status.pid ? ` (PID ${status.pid})` : ""}`
              : "Stopped"}
          </span>
        </div>

        {error && (
          <p className="text-destructive text-sm text-center">{error}</p>
        )}

        <div className="flex flex-col gap-2">
          {status.running ? (
            <>
              <Button
                variant="destructive"
                className="w-full"
                onClick={handleStop}
                disabled={loading === "stopping"}
              >
                {loading === "stopping" ? "Stopping..." : "Stop Daemon"}
              </Button>
              <Button
                variant="outline"
                className="w-full"
                onClick={handleShowQR}
                disabled={pairingLoading}
              >
                {pairingLoading ? "Loading..." : "Show Pairing QR Code"}
              </Button>
            </>
          ) : (
            <Button
              variant="default"
              className="w-full"
              onClick={handleStart}
              disabled={loading === "starting"}
            >
              {loading === "starting" ? "Starting..." : "Start Daemon"}
            </Button>
          )}
        </div>

        {agents.length > 0 && (
          <div className="space-y-2">
            <h2 className="text-sm font-medium text-muted-foreground">
              Detected Agents
            </h2>
            <div className="space-y-1">
              {agents.map((agent) => (
                <div
                  key={agent.id}
                  className="flex items-center gap-2 rounded-md border px-3 py-2 text-sm"
                >
                  <span
                    className={`inline-block w-2 h-2 rounded-full shrink-0 ${
                      agent.found ? "bg-green-500" : "bg-muted-foreground/30"
                    }`}
                  />
                  <div className="flex-1 min-w-0">
                    <p className="font-medium truncate">{agent.name}</p>
                    <p className="text-xs text-muted-foreground truncate">
                      {agent.found
                        ? agent.path ?? agent.command.join(" ")
                        : "Not detected"}
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        )}
      </div>

      <Dialog open={pairingOpen} onOpenChange={setPairingOpen}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>Pairing QR Code</DialogTitle>
            <DialogDescription>
              Scan this QR code with the Runmote mobile app, or enter the code
              below.
            </DialogDescription>
          </DialogHeader>
          {pairing && (
            <div className="flex flex-col items-center gap-4 py-4">
              {pairing.public_url && (
                <p className="text-xs text-muted-foreground text-center break-all">
                  Relay: {pairing.public_url}
                </p>
              )}
              <img
                src={pairing.qr_data_url}
                alt="Pairing QR Code"
                className="rounded-lg"
                width={300}
                height={300}
              />
              <div className="text-center">
                <p className="text-xs text-muted-foreground mb-1">
                  Or enter code:
                </p>
                <p className="text-2xl font-mono font-bold tracking-widest">
                  {pairing.formatted}
                </p>
              </div>
            </div>
          )}
        </DialogContent>
      </Dialog>

      <Dialog open={textCodeOpen} onOpenChange={setTextCodeOpen}>
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>Pairing Code</DialogTitle>
            <DialogDescription>
              Enter this code in the Runmote mobile app to pair.
            </DialogDescription>
          </DialogHeader>
          {textCode && (
            <div className="flex flex-col items-center gap-4 py-4">
              <p className="text-3xl font-mono font-bold tracking-widest">
                {textCode}
              </p>
            </div>
          )}
        </DialogContent>
      </Dialog>

      <AlertDialog open={uninstallOpen} onOpenChange={setUninstallOpen}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Uninstall Daemon</AlertDialogTitle>
            <AlertDialogDescription>
              This will stop the daemon, remove auto-start configuration, and
              clean up all temporary files. The application directory will not
              be deleted. Continue?
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel disabled={uninstalling}>
              Cancel
            </AlertDialogCancel>
            <AlertDialogAction
              onClick={handleUninstall}
              disabled={uninstalling}
            >
              {uninstalling ? "Uninstalling..." : "Uninstall"}
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <Dialog
        open={uninstallResultOpen}
        onOpenChange={setUninstallResultOpen}
      >
        <DialogContent className="sm:max-w-sm">
          <DialogHeader>
            <DialogTitle>Uninstall Complete</DialogTitle>
            <DialogDescription>
              The daemon has been removed. Details below.
            </DialogDescription>
          </DialogHeader>
          {uninstallResult && (
            <div className="space-y-2 py-2">
              <ResultRow
                label="Daemon stopped"
                ok={uninstallResult.daemon_stopped}
              />
              <ResultRow
                label="Auto-start removed"
                ok={uninstallResult.autostart_removed}
              />
              <ResultRow
                label="Wrapper scripts removed"
                ok={uninstallResult.wrapper_removed}
              />
              <ResultRow
                label="Config files cleaned"
                ok={uninstallResult.config_cleaned}
              />
              <ResultRow
                label="Temp files cleaned"
                ok={uninstallResult.temp_cleaned}
              />
              <ResultRow
                label="Agent CLIs removed"
                ok={uninstallResult.agents_removed}
              />
            </div>
          )}
        </DialogContent>
      </Dialog>
    </div>
  );
}

function ResultRow({ label, ok }: { label: string; ok: boolean }) {
  return (
    <div className="flex items-center gap-2 text-sm">
      <span
        className={`inline-block w-2 h-2 rounded-full shrink-0 ${
          ok ? "bg-green-500" : "bg-destructive"
        }`}
      />
      <span className={ok ? "" : "text-muted-foreground"}>{label}</span>
    </div>
  );
}

export default App;
