
SELECT l.No_Laporan,
       l.Status_Laporan,
       SUM(t.Nominal) AS total_nominal
FROM tb_transaksi t
JOIN tb_laporan l ON t.No_Laporan = l.No_Laporan
WHERE t.Nominal >= 40000000
GROUP BY l.No_Laporan, l.Status_Laporan;
