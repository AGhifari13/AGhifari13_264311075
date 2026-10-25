-- 1. Tabel induk: nasabah
CREATE TABLE tb_nasabah (
    ID_Nasabah     INT PRIMARY KEY,
    Nama_Nasabah   VARCHAR(100) NOT NULL,
    Jenis_Rekening VARCHAR(20)  NOT NULL,
    Status_Nasabah VARCHAR(20)  NOT NULL
);

-- 2. Tabel induk: laporan
CREATE TABLE tb_laporan (
    No_Laporan          VARCHAR(20)  PRIMARY KEY,
    Tanggal_Pemeriksaan DATE         NOT NULL,
    Status_Laporan      VARCHAR(100) NOT NULL
);

-- 3. Tabel anak: transaksi
CREATE TABLE tb_transaksi (
    ID_Transaksi       VARCHAR(10)   PRIMARY KEY,
    Tanggal_Pengiriman DATE          NOT NULL,
    ID_Pengirim        INT           NOT NULL,
    ID_Penerima        INT           NOT NULL,
    Nominal            DECIMAL(15,2) NOT NULL,
    Jenis_Transaksi    VARCHAR(30)   NOT NULL,
    No_Laporan         VARCHAR(20),
    Indikasi           VARCHAR(100),

    CONSTRAINT fk_pengirim FOREIGN KEY (ID_Pengirim)
        REFERENCES tb_nasabah (ID_Nasabah),
    CONSTRAINT fk_penerima FOREIGN KEY (ID_Penerima)
        REFERENCES tb_nasabah (ID_Nasabah),
    CONSTRAINT fk_laporan_trx FOREIGN KEY (No_Laporan)
        REFERENCES tb_laporan (No_Laporan),

    CONSTRAINT chk_nominal CHECK (Nominal > 0),
    CONSTRAINT chk_pengirim_penerima CHECK (ID_Pengirim <> ID_Penerima)
);

-- 4. Index untuk mempercepat JOIN dan pencarian
CREATE INDEX idx_trx_pengirim ON tb_transaksi (ID_Pengirim);
CREATE INDEX idx_trx_penerima ON tb_transaksi (ID_Penerima);
CREATE INDEX idx_trx_laporan  ON tb_transaksi (No_Laporan);

-- Mencoba menguji data 
INSERT INTO tb_nasabah VALUES
(1, 'Budi Santoso', 'Tabungan', 'Aktif'),
(2, 'Siti Aminah',  'Giro',     'Aktif'),
(3, 'Andi Wijaya',  'Giro',     'Dibekukan');

INSERT INTO tb_laporan VALUES
('LAP-001', '2026-10-20', 'Dalam Pemeriksaan');

INSERT INTO tb_transaksi VALUES
('TRX001', '2026-10-15', 1, 2, 250000000.00, 'Transfer', 'LAP-001', 'Nominal tidak wajar'),
('TRX002', '2026-10-16', 2, 1,   1500000.00, 'Transfer', NULL,      NULL),
('TRX003', '2026-10-17', 3, 1,  98000000.00, 'Transfer', 'LAP-001', 'Pola berulang');

--Transaksi lengkap dengan nama pengirim, penerima, dan status laporan
SELECT t.ID_Transaksi, t.Tanggal_Pengiriman,
       p.Nama_Nasabah AS Pengirim,
       r.Nama_Nasabah AS Penerima,
       t.Nominal, t.Indikasi, l.Status_Laporan
FROM tb_transaksi t
JOIN tb_nasabah p ON t.ID_Pengirim = p.ID_Nasabah
JOIN tb_nasabah r ON t.ID_Penerima = r.ID_Nasabah
LEFT JOIN tb_laporan l ON t.No_Laporan = l.No_Laporan;

--Transaksi yang ditandai mencurigakan
SELECT ID_Transaksi, Nominal, Indikasi, No_Laporan
FROM tb_transaksi
WHERE Indikasi IS NOT NULL;

--Total nominal yang dikirim tiap nasabah
SELECT n.Nama_Nasabah, SUM(t.Nominal) AS Total_Dikirim
FROM tb_nasabah n
JOIN tb_transaksi t ON n.ID_Nasabah = t.ID_Pengirim
GROUP BY n.Nama_Nasabah;

--Pengujian yang ditolak
-- Ditolak: pengirim 99 tidak ada di tb_nasabah (melanggar fk_pengirim)
INSERT INTO tb_transaksi VALUES
('TRX004', '2026-10-18', 99, 1, 1000000.00, 'Transfer', NULL, NULL);

-- Ditolak: nominal negatif (melanggar chk_nominal)
INSERT INTO tb_transaksi VALUES
('TRX005', '2026-10-18', 1, 2, -500.00, 'Transfer', NULL, NULL);

-- Ditolak: transfer ke diri sendiri (melanggar chk_pengirim_penerima)
INSERT INTO tb_transaksi VALUES
('TRX006', '2026-10-18', 1, 1, 100000.00, 'Transfer', NULL, NULL);
