export interface DaemonStatus {
  running: boolean;
  pid: number | null;
}

export interface PairingInfo {
  code: string;
  formatted: string;
  qr_data_url: string;
  public_url: string;
}

export interface AgentInfo {
  id: string;
  name: string;
  command: string[];
  found: boolean;
  path: string | null;
}

export interface UninstallResult {
  daemon_stopped: boolean;
  autostart_removed: boolean;
  wrapper_removed: boolean;
  config_cleaned: boolean;
  temp_cleaned: boolean;
}
