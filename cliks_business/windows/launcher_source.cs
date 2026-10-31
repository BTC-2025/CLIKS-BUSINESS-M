using System;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

class CliksBusinessLauncher {
    [STAThread]
    static void Main(string[] args) {
        try {
            string localAppData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            string appDataPath = Path.Combine(localAppData, "Programs", "Cliks Business", "Cliks Business.exe");
            
            string desktop = Environment.GetFolderPath(Environment.SpecialFolder.Desktop);
            string desktopPath = Path.Combine(desktop, "Cliks Business Release", "Cliks Business.exe");

            string targetExe = null;
            string targetDir = null;

            if (File.Exists(appDataPath)) {
                targetExe = appDataPath;
                targetDir = Path.GetDirectoryName(appDataPath);
            } else if (File.Exists(desktopPath)) {
                targetExe = desktopPath;
                targetDir = Path.GetDirectoryName(desktopPath);
            }

            if (targetExe != null) {
                ProcessStartInfo psi = new ProcessStartInfo {
                    FileName = targetExe,
                    WorkingDirectory = targetDir,
                    Arguments = string.Join(" ", args),
                    UseShellExecute = true
                };
                Process.Start(psi);
            } else {
                MessageBox.Show(
                    "Could not locate Cliks Business in AppData or Desktop.\nPlease reinstall the application.",
                    "Cliks Business",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error
                );
            }
        } catch (Exception ex) {
            MessageBox.Show(
                "Failed to launch Cliks Business: " + ex.Message,
                "Cliks Business Error",
                MessageBoxButtons.OK,
                MessageBoxIcon.Error
            );
        }
    }
}

