# AutoCAD AutoLISP + Visual Studio .NET Plugin

Proyek ini mendemonstrasikan kolaborasi antara **AutoLISP** (untuk AutoCAD) dan
**Visual Studio C#** yang menghasilkan file `.dll` yang dapat dimuat langsung ke AutoCAD.

---

## Struktur Folder

```
autolisp/
  autocad_commands.lsp   AutoLISP commands untuk AutoCAD
  load_plugin.lsp        Skrip pemuat AutoCADPlugin.dll

dotnet/
  AutoCADPlugin/
    AutoCADPlugin.csproj  Visual Studio project (C#, .NET 4.8)
    Plugin.cs             IExtensionApplication – inisialisasi plugin
    Commands.cs           Definisi perintah AutoCAD dari .NET
```

---

## Cara Membangun dan Menggunakan

### 1. Kompilasi .dll dengan Visual Studio

1. Buka **Visual Studio 2019/2022**.
2. Buka file solusi atau project `dotnet/AutoCADPlugin/AutoCADPlugin.csproj`.
3. Setel variabel MSBuild `AcadInstallPath` di project properties atau di
   `.csproj` agar menunjuk ke folder instalasi AutoCAD Anda, misalnya:
   ```
   C:\Program Files\Autodesk\AutoCAD 2024\
   ```
4. Build project (**Build → Build Solution** atau `Ctrl+Shift+B`).
5. File `AutoCADPlugin.dll` akan tersedia di folder `bin\Release\`.

### 2. Muat Plugin ke AutoCAD via AutoLISP

Ada dua cara:

**Cara A – Otomatis melalui `load_plugin.lsp`:**
```lisp
(load "C:\\path\\ke\\autolisp\\load_plugin.lsp")
```

**Cara B – Manual melalui `NETLOAD`:**
```
Command: NETLOAD
↳ Pilih file: C:\path\ke\AutoCADPlugin.dll
```

### 3. Muat AutoLISP Commands

```lisp
(load "C:\\path\\ke\\autolisp\\autocad_commands.lsp")
```

---

## Perintah yang Tersedia

### Perintah AutoLISP (`.lsp`)

| Perintah          | Deskripsi                                    |
|-------------------|----------------------------------------------|
| `GAMBAR-GARIS`    | Menggambar garis dari dua titik              |
| `GAMBAR-LINGKARAN`| Menggambar lingkaran dari pusat dan radius   |
| `GAMBAR-PERSEGI`  | Menggambar persegi panjang dari dua sudut    |
| `HITUNG-LUAS`     | Menghitung luas dan keliling polyline        |
| `BUAT-LAYER`      | Membuat layer baru dengan warna ACI          |
| `EKSPOR-CSV`      | Mengekspor koordinat garis ke file CSV       |
| `PANGGIL-DOTNET`  | Memanggil perintah dari AutoCADPlugin.dll    |

### Perintah .NET / Visual Studio (`.dll`)

| Perintah           | Deskripsi                                     |
|--------------------|-----------------------------------------------|
| `PLUGININFO`       | Menampilkan informasi versi plugin             |
| `PLUGINDRAW`       | Menggambar lingkaran + garis silang di origin |
| `PLUGINEXPORT`     | Mengekspor entitas LINE ke CSV                |
| `PLUGINBLOCKLIST`  | Menampilkan daftar semua block dalam gambar   |

---

## Cara Kerja Kolaborasi AutoLISP ↔ .NET

```
AutoCAD
  │
  ├─ load_plugin.lsp   →  (command "_.NETLOAD" "AutoCADPlugin.dll")
  │                              │
  │                              ▼
  │                     Plugin.cs (Initialize)
  │                     Commands.cs (PLUGININFO, PLUGINDRAW, ...)
  │
  └─ autocad_commands.lsp  →  c:GAMBAR-GARIS, c:EKSPOR-CSV, ...
                               c:PANGGIL-DOTNET  →  (command "_.PLUGINDRAW")
```

AutoLISP dan .NET berjalan di dalam proses AutoCAD yang sama, sehingga:
- AutoLISP dapat memanggil perintah .NET menggunakan `(command "_.NAMACOMMAND")`.
- Keduanya mengakses database gambar AutoCAD yang sama.

---

## Persyaratan

| Komponen        | Versi Minimum        |
|-----------------|----------------------|
| AutoCAD         | 2020 (atau lebih baru) |
| Visual Studio   | 2019 / 2022          |
| .NET Framework  | 4.8                  |
| AutoCAD API     | AcMgd.dll, AcDbMgd.dll, AcCoreMgd.dll |
