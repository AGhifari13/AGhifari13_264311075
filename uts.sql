-- Nominal harus positif
ALTER TABLE tb_transaksi
  ADD CONSTRAINT chk_nominal CHECK (Nominal > 0);

-- Pengirim dan penerima tidak boleh sama
ALTER TABLE tb_transaksi
  ADD CONSTRAINT chk_beda_nasabah CHECK (ID_Pengirim <> ID_Penerima);

-- Batasi isi kolom status
ALTER TABLE tb_nasabah
  ADD CONSTRAINT chk_status_nasabah
  CHECK (Status_Nasabah IN ('Aktif', 'Nonaktif', 'Diblokir'));
