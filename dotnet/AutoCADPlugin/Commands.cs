using System;
using System.IO;
using System.Text;
using Autodesk.AutoCAD.ApplicationServices;
using Autodesk.AutoCAD.DatabaseServices;
using Autodesk.AutoCAD.EditorInput;
using Autodesk.AutoCAD.Geometry;
using Autodesk.AutoCAD.Runtime;

namespace AutoCADPlugin
{
    /// <summary>
    /// Kumpulan perintah AutoCAD yang didefinisikan dalam .NET (Visual Studio).
    /// Perintah-perintah ini dapat dipanggil langsung dari AutoCAD command line
    /// maupun dari AutoLISP menggunakan (command "_.NAMACOMMAND").
    /// </summary>
    public class Commands
    {
        // ----------------------------------------------------------------
        // 1. PLUGININFO
        // Menampilkan informasi versi dan status plugin.
        // ----------------------------------------------------------------
        [CommandMethod("PLUGININFO")]
        public void ShowPluginInfo()
        {
            var doc = Application.DocumentManager.MdiActiveDocument;
            var ed  = doc.Editor;

            ed.WriteMessage(
                "\n==============================================\n" +
                "  AutoCADPlugin - Informasi\n" +
                "  Versi    : 1.0.0\n" +
                "  Platform : AutoCAD .NET API (Visual Studio)\n" +
                "  Kolaborasi dengan AutoLISP (autocad_commands.lsp)\n" +
                "==============================================\n");
        }

        // ----------------------------------------------------------------
        // 2. PLUGINDRAW
        // Menggambar objek contoh (lingkaran + garis silang) di origin.
        // ----------------------------------------------------------------
        [CommandMethod("PLUGINDRAW")]
        public void DrawSampleObjects()
        {
            var doc = Application.DocumentManager.MdiActiveDocument;
            var db  = doc.Database;
            var ed  = doc.Editor;

            using (var tr = db.TransactionManager.StartTransaction())
            {
                var bt  = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
                var btr = (BlockTableRecord)tr.GetObject(
                              bt[BlockTableRecord.ModelSpace], OpenMode.ForWrite);

                // Gambar lingkaran di titik (0,0,0) dengan radius 50
                var circle = new Circle(Point3d.Origin, Vector3d.ZAxis, 50.0);
                btr.AppendEntity(circle);
                tr.AddNewlyCreatedDBObject(circle, true);

                // Gambar garis horizontal melewati origin
                var hLine = new Line(new Point3d(-60, 0, 0), new Point3d(60, 0, 0));
                btr.AppendEntity(hLine);
                tr.AddNewlyCreatedDBObject(hLine, true);

                // Gambar garis vertikal melewati origin
                var vLine = new Line(new Point3d(0, -60, 0), new Point3d(0, 60, 0));
                btr.AppendEntity(vLine);
                tr.AddNewlyCreatedDBObject(vLine, true);

                tr.Commit();
            }

            ed.WriteMessage("\n[OK] Objek contoh (lingkaran + silang) berhasil digambar di origin.\n");
        }

        // ----------------------------------------------------------------
        // 3. PLUGINEXPORT
        // Mengekspor semua entitas LINE dalam gambar aktif ke file CSV.
        // ----------------------------------------------------------------
        [CommandMethod("PLUGINEXPORT")]
        public void ExportLinesToCsv()
        {
            var doc = Application.DocumentManager.MdiActiveDocument;
            var db  = doc.Database;
            var ed  = doc.Editor;

            // Minta pengguna menentukan path file output
            var pso = new PromptSaveFileOptions(
                "\nSimpan file CSV sebagai: ")
            {
                Filter         = "CSV Files (*.csv)|*.csv",
                DefaultExtension = "csv"
            };
            var psr = ed.GetFileNameForSave(pso);
            if (psr.Status != PromptStatus.OK)
            {
                ed.WriteMessage("\n[BATAL] Ekspor dibatalkan.\n");
                return;
            }

            var outputPath = psr.StringResult;
            int count      = 0;

            using (var tr  = db.TransactionManager.StartTransaction())
            using (var sw  = new StreamWriter(outputPath, false, Encoding.UTF8))
            {
                // Header CSV
                sw.WriteLine("Tipe,X1,Y1,Z1,X2,Y2,Z2,Layer");

                var bt  = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
                var btr = (BlockTableRecord)tr.GetObject(
                              bt[BlockTableRecord.ModelSpace], OpenMode.ForRead);

                foreach (ObjectId objId in btr)
                {
                    var entity = tr.GetObject(objId, OpenMode.ForRead) as Line;
                    if (entity == null) continue;

                    sw.WriteLine(string.Format(
                        "LINE,{0},{1},{2},{3},{4},{5},{6}",
                        entity.StartPoint.X.ToString("F4"),
                        entity.StartPoint.Y.ToString("F4"),
                        entity.StartPoint.Z.ToString("F4"),
                        entity.EndPoint.X.ToString("F4"),
                        entity.EndPoint.Y.ToString("F4"),
                        entity.EndPoint.Z.ToString("F4"),
                        entity.Layer));

                    count++;
                }

                tr.Commit();
            }

            ed.WriteMessage(
                $"\n[OK] {count} entitas LINE diekspor ke: {outputPath}\n");
        }

        // ----------------------------------------------------------------
        // 4. PLUGINBLOCKLIST
        // Menampilkan daftar semua block definition dalam gambar.
        // ----------------------------------------------------------------
        [CommandMethod("PLUGINBLOCKLIST")]
        public void ListBlocks()
        {
            var doc = Application.DocumentManager.MdiActiveDocument;
            var db  = doc.Database;
            var ed  = doc.Editor;

            var sb = new StringBuilder();
            sb.AppendLine("\n--- Daftar Block dalam Gambar ---");

            using (var tr = db.TransactionManager.StartTransaction())
            {
                var bt = (BlockTable)tr.GetObject(db.BlockTableId, OpenMode.ForRead);
                foreach (ObjectId btId in bt)
                {
                    var btr = (BlockTableRecord)tr.GetObject(btId, OpenMode.ForRead);
                    if (!btr.IsAnonymous && !btr.IsLayout)
                    {
                        sb.AppendLine($"  Block: {btr.Name}");
                    }
                }
                tr.Commit();
            }

            sb.AppendLine("---------------------------------");
            ed.WriteMessage(sb.ToString());
        }
    }
}
