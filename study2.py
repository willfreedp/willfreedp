import pandas as pd
import openpyxl

def csv_to_excel_template(csv_file, excel_file, sheet_name, start_cell):
    """
    Memasukkan data dari CSV ke Excel template
    
    Parameters:
    - csv_file: path file CSV
    - excel_file: path file Excel template
    - sheet_name: nama sheet tujuan (contoh: "abc")
    - start_cell: sel awal tujuan (contoh: "C3")
    """
    
    # Baca CSV
    df = pd.read_csv(csv_file)
    csv_column_A = df.iloc[:, 0].tolist()  # Ambil kolom pertama (A)
    
    # Buka Excel template (format tetap terjaga)
    wb = openpyxl.load_workbook(excel_file)
    ws = wb[sheet_name]
    
    # Parse start cell (contoh "C3" -> kolom 3, baris 3)
    from openpyxl.utils.cell import coordinate_to_tuple
    start_row, start_col = coordinate_to_tuple(start_cell)
    
    # Tulis data ke Excel
    for i, value in enumerate(csv_column_A):
        ws.cell(row=start_row + i, column=start_col, value=value)
    
    # Simpan (overwrite file yang sama)
    wb.save(excel_file)
    print(f"✅ Berhasil memasukkan {len(csv_column_A)} baris data ke {excel_file} > Sheet '{sheet_name}' mulai {start_cell}")

# ============================================================
# CONTOH PENGGUNAAN - sesuaikan path file Anda
# ============================================================
csv_to_excel_template(
    csv_file="data_autocad.csv",      # File CSV dari AutoCAD
    excel_file="template.xlsx",        # File Excel template Anda
    sheet_name="abc",                  # Nama sheet tujuan
    start_cell="C3"                    # Mulai dari sel C3
)
