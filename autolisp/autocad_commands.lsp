;;; ============================================================
;;; autocad_commands.lsp
;;; Kumpulan perintah AutoLISP untuk AutoCAD yang berkolaborasi
;;; dengan AutoCADPlugin.dll (dibuat dari Visual Studio / C#).
;;;
;;; Perintah yang tersedia:
;;;   GAMBAR-GARIS     - Menggambar garis dari dua titik
;;;   GAMBAR-LINGKARAN - Menggambar lingkaran dari titik pusat dan radius
;;;   GAMBAR-PERSEGI   - Menggambar persegi panjang dari dua sudut
;;;   HITUNG-LUAS      - Menghitung luas polyline yang dipilih
;;;   BUAT-LAYER       - Membuat layer baru dengan warna tertentu
;;;   EKSPOR-CSV       - Mengekspor data atribut ke file CSV
;;;   PANGGIL-DOTNET   - Memanggil perintah yang terdefinisi di .dll
;;; ============================================================

;;; ============================================================
;;; 1. GAMBAR-GARIS
;;; Menggambar garis berdasarkan input koordinat pengguna.
;;; ============================================================
(defun c:GAMBAR-GARIS (/ pt1 pt2)
  "Menggambar garis dari dua titik yang ditentukan pengguna."
  (setq pt1 (getpoint "\nTitik awal: "))
  (if pt1
    (progn
      (setq pt2 (getpoint pt1 "\nTitik akhir: "))
      (if pt2
        (progn
          (command "_.LINE" pt1 pt2 "")
          (princ "\n[OK] Garis berhasil digambar.\n"))
        (princ "\n[BATAL] Titik akhir tidak dimasukkan.\n")))
    (princ "\n[BATAL] Titik awal tidak dimasukkan.\n"))
  (princ))

;;; ============================================================
;;; 2. GAMBAR-LINGKARAN
;;; Menggambar lingkaran berdasarkan titik pusat dan radius.
;;; ============================================================
(defun c:GAMBAR-LINGKARAN (/ center radius)
  "Menggambar lingkaran dari titik pusat dan radius."
  (setq center (getpoint "\nTitik pusat lingkaran: "))
  (if center
    (progn
      (setq radius (getdist center "\nRadius: "))
      (if (and radius (> radius 0))
        (progn
          (command "_.CIRCLE" center radius)
          (princ "\n[OK] Lingkaran berhasil digambar.\n"))
        (princ "\n[BATAL] Radius tidak valid.\n")))
    (princ "\n[BATAL] Titik pusat tidak dimasukkan.\n"))
  (princ))

;;; ============================================================
;;; 3. GAMBAR-PERSEGI
;;; Menggambar persegi panjang dari dua sudut yang berlawanan.
;;; ============================================================
(defun c:GAMBAR-PERSEGI (/ pt1 pt2)
  "Menggambar persegi panjang dari dua sudut yang berlawanan."
  (setq pt1 (getpoint "\nSudut pertama: "))
  (if pt1
    (progn
      (setq pt2 (getcorner pt1 "\nSudut berlawanan: "))
      (if pt2
        (progn
          (command "_.RECTANG" pt1 pt2)
          (princ "\n[OK] Persegi panjang berhasil digambar.\n"))
        (princ "\n[BATAL] Sudut berlawanan tidak dimasukkan.\n")))
    (princ "\n[BATAL] Sudut pertama tidak dimasukkan.\n"))
  (princ))

;;; ============================================================
;;; 4. HITUNG-LUAS
;;; Menghitung dan menampilkan luas dari polyline yang dipilih.
;;; ============================================================
(defun c:HITUNG-LUAS (/ sel obj area perimeter)
  "Menghitung luas dan keliling dari polyline yang dipilih."
  (setq sel (entsel "\nPilih polyline: "))
  (if sel
    (progn
      (setq obj (car sel))
      (setq area      (vlax-get-property (vlax-ename->vla-object obj) 'Area))
      (setq perimeter (vlax-get-property (vlax-ename->vla-object obj) 'Length))
      (princ (strcat "\n--- Hasil Perhitungan ---"
                     "\n  Luas      : " (rtos area 2 4) " unit²"
                     "\n  Keliling  : " (rtos perimeter 2 4) " unit"
                     "\n------------------------\n")))
    (princ "\n[BATAL] Tidak ada objek yang dipilih.\n"))
  (princ))

;;; ============================================================
;;; 5. BUAT-LAYER
;;; Membuat layer baru dengan nama dan nomor warna ACI.
;;; ============================================================
(defun c:BUAT-LAYER (/ nama-layer warna)
  "Membuat layer baru dengan nama dan warna yang ditentukan."
  (setq nama-layer (getstring T "\nNama layer baru: "))
  (if (and nama-layer (/= nama-layer ""))
    (progn
      (setq warna (getint "\nNomor warna ACI (1-255): "))
      (if (and warna (>= warna 1) (<= warna 255))
        (progn
          (command "_.LAYER" "N" nama-layer "C" (itoa warna) nama-layer "")
          (princ (strcat "\n[OK] Layer '" nama-layer "' dibuat dengan warna " (itoa warna) ".\n")))
        (progn
          (command "_.LAYER" "N" nama-layer "")
          (princ (strcat "\n[OK] Layer '" nama-layer "' dibuat (warna default).\n")))))
    (princ "\n[BATAL] Nama layer tidak valid.\n"))
  (princ))

;;; ============================================================
;;; 6. EKSPOR-CSV
;;; Mengekspor koordinat semua entitas LINE dalam gambar ke CSV.
;;; ============================================================
(defun c:EKSPOR-CSV (/ output-file file-handle ss idx ent ent-data
                       pt1 pt2 line)
  "Mengekspor koordinat semua garis (LINE) dalam gambar ke file CSV."
  (setq output-file
    (getfiled "Simpan sebagai CSV" "" "csv" 1))
  (if output-file
    (progn
      (setq file-handle (open output-file "w"))
      (write-line "Tipe,X1,Y1,Z1,X2,Y2,Z2" file-handle)
      (setq ss (ssget "X" '((0 . "LINE"))))
      (if ss
        (progn
          (setq idx 0)
          (while (< idx (sslength ss))
            (setq ent      (ssname ss idx)
                  ent-data (entget ent)
                  pt1      (cdr (assoc 10 ent-data))
                  pt2      (cdr (assoc 11 ent-data))
                  line     (strcat "LINE,"
                                   (rtos (car pt1) 2 4) ","
                                   (rtos (cadr pt1) 2 4) ","
                                   (rtos (caddr pt1) 2 4) ","
                                   (rtos (car pt2) 2 4) ","
                                   (rtos (cadr pt2) 2 4) ","
                                   (rtos (caddr pt2) 2 4)))
            (write-line line file-handle)
            (setq idx (1+ idx)))
          (close file-handle)
          (princ (strcat "\n[OK] " (itoa (sslength ss))
                         " garis diekspor ke: " output-file "\n")))
        (progn
          (close file-handle)
          (princ "\n[INFO] Tidak ada entitas LINE ditemukan dalam gambar.\n"))))
    (princ "\n[BATAL] Tidak ada file yang dipilih.\n"))
  (princ))

;;; ============================================================
;;; 7. PANGGIL-DOTNET
;;; Memanggil perintah AutoCAD yang didefinisikan di dalam
;;; AutoCADPlugin.dll (dikompilasi dari Visual Studio).
;;; Pastikan DLL sudah dimuat via load_plugin.lsp.
;;; ============================================================
(defun c:PANGGIL-DOTNET (/ pilihan)
  "Menampilkan menu dan memanggil perintah dari AutoCADPlugin.dll."
  (initget "Info Gambar Ekspor")
  (setq pilihan
    (getkword
      (strcat "\nPilih perintah .NET [Info/Gambar/Ekspor] <Info>: ")))
  (if (not pilihan) (setq pilihan "Info"))
  (cond
    ((= pilihan "Info")
     (command "_.PLUGININFO"))
    ((= pilihan "Gambar")
     (command "_.PLUGINDRAW"))
    ((= pilihan "Ekspor")
     (command "_.PLUGINEXPORT")))
  (princ))

;;; ============================================================
;;; Pesan selamat datang saat file dimuat
;;; ============================================================
(princ "\n==============================================")
(princ "\n  AutoCAD AutoLISP + .NET Plugin Commands")
(princ "\n==============================================")
(princ "\n  GAMBAR-GARIS     - Gambar garis")
(princ "\n  GAMBAR-LINGKARAN - Gambar lingkaran")
(princ "\n  GAMBAR-PERSEGI   - Gambar persegi panjang")
(princ "\n  HITUNG-LUAS      - Hitung luas polyline")
(princ "\n  BUAT-LAYER       - Buat layer baru")
(princ "\n  EKSPOR-CSV       - Ekspor garis ke CSV")
(princ "\n  PANGGIL-DOTNET   - Panggil perintah .NET DLL")
(princ "\n==============================================\n")
(princ)
