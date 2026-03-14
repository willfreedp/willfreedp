using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.Runtime;

[assembly: ExtensionApplication(typeof(AutoCADPlugin.Plugin))]

namespace AutoCADPlugin
{
    /// <summary>
    /// Titik masuk plugin AutoCAD .NET.
    /// Kelas ini dijalankan otomatis oleh AutoCAD saat .dll dimuat
    /// melalui perintah NETLOAD atau AutoLISP (command "_.NETLOAD" ...).
    /// </summary>
    public class Plugin : IExtensionApplication
    {
        /// <summary>
        /// Dijalankan sekali saat .dll pertama kali dimuat ke AutoCAD.
        /// </summary>
        public void Initialize()
        {
            var doc = Application.DocumentManager.MdiActiveDocument;
            if (doc != null)
            {
                doc.Editor.WriteMessage(
                    "\n==============================================\n" +
                    "  AutoCADPlugin .NET berhasil dimuat!\n" +
                    "  Perintah tersedia:\n" +
                    "    PLUGININFO       - Info plugin\n" +
                    "    PLUGINDRAW       - Gambar objek contoh\n" +
                    "    PLUGINEXPORT     - Ekspor data gambar ke CSV\n" +
                    "    PLUGINBLOCKLIST  - Daftar block dalam gambar\n" +
                    "==============================================\n");
            }
        }

        /// <summary>
        /// Dijalankan saat AutoCAD ditutup atau .dll di-unload.
        /// </summary>
        public void Terminate()
        {
            // Pembersihan resource jika diperlukan
        }
    }
}
