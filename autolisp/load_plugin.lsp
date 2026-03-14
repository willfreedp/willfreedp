;;; ============================================================
;;; load_plugin.lsp
;;; Skrip AutoLISP untuk memuat plugin .NET (AutoCADPlugin.dll)
;;; yang dikompilasi dari Visual Studio ke dalam AutoCAD.
;;;
;;; Cara penggunaan:
;;;   1. Kompilasi AutoCADPlugin.csproj di Visual Studio terlebih dahulu.
;;;   2. Di AutoCAD, jalankan perintah APPLOAD lalu pilih load_plugin.lsp,
;;;      atau ketik (load "load_plugin.lsp") di command line AutoCAD.
;;;   3. Jika .dll tidak ditemukan pada path default, Anda akan diminta
;;;      memilih file secara manual.
;;; ============================================================

(defun load-autocad-plugin (/ dll-path default-path)
  "Memuat AutoCADPlugin.dll ke AutoCAD menggunakan NETLOAD."
  ;; Path default – disesuaikan dengan lokasi lsp file ini
  (setq default-path
    (strcat (getenv "USERPROFILE")
            "\\source\\repos\\AutoCADPlugin\\bin\\Release\\AutoCADPlugin.dll"))

  (setq dll-path
    (cond
      ;; Coba path default terlebih dahulu
      ((findfile default-path) default-path)
      ;; Jika tidak ada, minta pengguna memilih file secara manual
      (T
       (princ "\n[INFO] File .dll tidak ditemukan pada path default.\n")
       (getfiled "Pilih AutoCADPlugin.dll" "" "dll" 0))))

  (cond
    ((not dll-path)
     (princ "\n[BATAL] Tidak ada file .dll yang dipilih.\n")
     nil)
    ((findfile dll-path)
     (command "_.NETLOAD" dll-path)
     (princ (strcat "\n[OK] Plugin berhasil dimuat: " dll-path "\n"))
     T)
    (T
     (princ (strcat "\n[ERROR] File tidak ditemukan: " dll-path "\n"))
     (princ "Pastikan AutoCADPlugin.dll sudah dikompilasi dari Visual Studio.\n")
     nil)))

;;; Muat plugin secara otomatis saat file ini di-load
(load-autocad-plugin)

(princ "\nload_plugin.lsp dimuat. Plugin .NET siap digunakan.\n")
(princ)
