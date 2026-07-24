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
import {
  Play,
  Square,
  QrCode,
  Trash2,
  Bot,
  AlertCircle,
  CheckCircle2,
  XCircle,
  Loader2,
} from "lucide-react";
import type {
  DaemonStatus,
  PairingInfo,
  AgentInfo,
  UninstallResult,
} from "./types";
import Logo from "./assets/logo.png";

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
      <div className="max-w-sm w-full space-y-8">
        <div className="text-center space-y-4">
          <div className="flex justify-center">
            <img
              src={Logo}
              alt="Runmote logo"
              className="w-20 h-20 drop-shadow-sm"
            />
          </div>
          <div className="space-y-1">
            <h1 className="text-3xl font-bold tracking-tight">Runmote</h1>
            <p className="text-muted-foreground text-sm">
              Remote control for your coding agents
            </p>
          </div>
        </div>

        <div className="flex items-center justify-center gap-2.5 rounded-full border bg-card px-4 py-2 text-sm shadow-sm">
          {status.running ? (
            <>
              <span className="relative flex h-2.5 w-2.5">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-500 opacity-75" />
                <span className="relative inline-flex rounded-full h-2.5 w-2.5 bg-emerald-500" />
              </span>
              <span className="text-foreground font-medium">
                Daemon running
                {status.pid ? ` · PID ${status.pid}` : ""}
              </span>
            </>
          ) : (
            <>
              <XCircle className="h-4 w-4 text-muted-foreground" />
              <span className="text-muted-foreground">Daemon stopped</span>
            </>
          )}
        </div>

        {error && (
          <div className="flex items-start gap-2 rounded-lg border border-destructive/30 bg-destructive/10 p-3 text-sm text-destructive">
            <AlertCircle className="h-4 w-4 shrink-0 mt-0.5" />
            <span className="break-words">{error}</span>
          </div>
        )}

        <div className="flex flex-col gap-2.5">
          {status.running ? (
            <>
              <Button
                variant="destructive"
                className="w-full h-11"
                onClick={handleStop}
                disabled={loading === "stopping"}
              >
                {loading === "stopping" ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <Square className="mr-2 h-4 w-4" />
                )}
                {loading === "stopping" ? "Stopping..." : "Stop Daemon"}
              </Button>
              <Button
                variant="outline"
                className="w-full h-11"
                onClick={handleShowQR}
                disabled={pairingLoading}
              >
                {pairingLoading ? (
                  <Loader2 className="mr-2 h-4 w-4 animate-spin" />
                ) : (
                  <QrCode className="mr-2 h-4 w-4" />
                )}
                {pairingLoading ? "Loading..." : "Show Pairing Code"}
              </Button>
            </>
          ) : (
            <Button
              variant="default"
              className="w-full h-11"
              onClick={handleStart}
              disabled={loading === "starting"}
            >
              {loading === "starting" ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : (
                <Play className="mr-2 h-4 w-4" />
              )}
              {loading === "starting" ? "Starting..." : "Start Daemon"}
            </Button>
          )}
        </div>

        {agents.length > 0 && (
          <div className="space-y-3">
            <h2 className="text-xs font-semibold uppercase tracking-wider text-muted-foreground">
              Detected Agents
            </h2>
            <div className="space-y-2">
              {agents.map((agent) => (
                <div
                  key={agent.id}
                  className="flex items-center gap-3 rounded-xl border bg-card px-4 py-3 text-sm shadow-sm"
                >
                  <Bot className="h-4 w-4 text-muted-foreground shrink-0" />
                  <div className="flex-1 min-w-0">
                    <p className="font-medium truncate">{agent.name}</p>
                    <p className="text-xs text-muted-foreground truncate">
                      {agent.found
                        ? agent.path ?? agent.command.join(" ")
                        : "Not detected"}
                    </p>
                  </div>
                  <span
                    className={`inline-flex h-2.5 w-2.5 rounded-full shrink-0 ${
                      agent.found ? "bg-emerald-500" : "bg-muted-foreground/30"
                    }`}
                    title={agent.found ? "Available" : "Unavailable"}
                  />
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
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
            >
              {uninstalling ? (
                <Loader2 className="mr-2 h-4 w-4 animate-spin" />
              ) : (
                <Trash2 className="mr-2 h-4 w-4" />
              )}
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
              <ResultRow
                label="Bundled data cleaned"
                ok={uninstallResult.app_data_cleaned}
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
    <div className="flex items-center gap-3 text-sm">
      {ok ? (
        <CheckCircle2 className="h-4 w-4 text-emerald-600 shrink-0" />
      ) : (
        <XCircle className="h-4 w-4 text-destructive shrink-0" />
      )}
      <span className={ok ? "" : "text-muted-foreground"}>{label}</span>
    </div>
  );
}

export default App;
